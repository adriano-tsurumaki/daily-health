module Finance
  class DashboardBuilder
    UNCATEGORIZED_LABEL = "Sem categoria".freeze

    def initialize(user:, month:, year:)
      @user = user
      @month = month
      @year = year
      @start_date = Date.new(year, month, 1)
      @end_date = @start_date.end_of_month
      @bucket = format("%<year>04d-%<month>02d", year: year, month: month)
    end

    def as_json(*)
      {
        period: {
          month: month,
          year: year,
          bucket: bucket,
          starts_on: start_date,
          ends_on: end_date
        },
        summary: summary,
        alerts: alerts,
        review_queue: review_queue,
        instrument_snapshots: instrument_snapshots,
        upcoming_timeline: upcoming_timeline,
        budget_health: budget_health,
        rankings: rankings,
        recent_activity: recent_activity
      }
    end

    private

    attr_reader :bucket, :end_date, :month, :start_date, :user, :year

    def summary
      {
        available: realized_income - realized_expenses,
        committed_this_month: total_expenses,
        upcoming_charges: committed_expenses + predicted_expenses,
        projected_surplus: total_income - total_expenses,
        realized: {
          income: realized_income,
          expense: realized_expenses
        },
        predicted: {
          income: committed_income + predicted_income,
          expense: committed_expenses + predicted_expenses
        }
      }
    end

    def alerts
      entries = []

      if review_queue[:total] > 0
        entries << {
          id: "review-queue",
          level: "warning",
          title: "Pending reviews",
          description: "#{review_queue[:total]} items need review for an accurate monthly reading."
        }
      end

      budget_health.select { |item| %w[attention over_limit].include?(item[:status]) }.first(3).each do |item|
        entries << {
          id: "budget-#{item[:id] || item[:label].parameterize}",
          level: item[:status] == "over_limit" ? "danger" : "warning",
          title: "#{item[:label]} above expected",
          description: "Spent #{formatted_currency(item[:spent])} of a monthly limit of #{formatted_currency(item[:monthly_limit])}."
        }
      end

      instrument_snapshots.select { |snapshot| snapshot[:utilization].to_f >= 80 }.each do |snapshot|
        entries << {
          id: "instrument-#{snapshot[:id]}",
          level: "warning",
          title: "#{snapshot[:name]} near limit",
          description: "Usage at #{snapshot[:utilization].round(1)}% of credit limit."
        }
      end

      entries.first(6)
    end

    def review_queue
      @review_queue ||= begin
        uncategorized_transactions = actual_entries.select { |entry| entry[:review_status] == "needs_category" }
        incomplete_instruments = payment_methods.select { |payment_method| payment_method.review_status != "ok" }
        broken_recurrences = active_recurrences.select { |recurrence| recurrence.review_status != "ok" }

        {
          total: uncategorized_transactions.size + incomplete_instruments.size + broken_recurrences.size,
          uncategorized_count: uncategorized_transactions.size,
          incomplete_instruments_count: incomplete_instruments.size,
          broken_recurrences_count: broken_recurrences.size,
          items: (
            uncategorized_transactions.first(4).map do |entry|
              {
                type: "transaction",
                id: entry[:source_id],
                title: entry[:title],
                review_status: entry[:review_status]
              }
            end +
            incomplete_instruments.first(3).map do |payment_method|
              {
                type: "instrument",
                id: payment_method.id,
                title: payment_method.name,
                review_status: payment_method.review_status
              }
            end +
            broken_recurrences.first(3).map do |recurrence|
              {
                type: "recurrence",
                id: recurrence.id,
                title: recurrence.name,
                review_status: recurrence.review_status
              }
            end
          ).first(8)
        }
      end
    end

    def instrument_snapshots
      @instrument_snapshots ||= payment_methods.map do |payment_method|
        instrument_entries = period_entries.select { |entry| entry[:payment_method_id] == payment_method.id }
        outflow = expense_total(instrument_entries)

        {
          id: payment_method.id,
          name: payment_method.name,
          kind: payment_method.kind,
          is_active: payment_method.is_active,
          display_color: payment_method.display_color,
          review_status: payment_method.review_status,
          closing_day: payment_method.closing_day,
          due_day: payment_method.due_day,
          credit_limit: payment_method.credit_limit,
          committed_amount: outflow,
          realized_amount: expense_total(instrument_entries.select { |entry| entry[:entry_state] == "realized" }),
          pending_amount: expense_total(instrument_entries.reject { |entry| entry[:entry_state] == "realized" }),
          utilization: utilization_for(payment_method, outflow),
          remaining_limit: remaining_limit_for(payment_method, outflow)
        }
      end
    end

    def upcoming_timeline
      period_entries
        .sort_by { |entry| [ entry[:commitment_date], entry[:amount] ] }
        .first(12)
        .map do |entry|
          {
            type: entry[:source_type],
            id: entry[:source_id],
            title: entry[:title],
            amount: entry[:amount],
            commitment_date: entry[:commitment_date],
            entry_state: entry[:entry_state],
            review_status: entry[:review_status],
            category_name: entry[:category_name],
            payment_method_name: entry[:payment_method_name]
          }
        end
    end

    def budget_health
      tracked_categories = user.categories.kept.order(:name).map do |category|
        category_entries = expense_entries.select { |entry| entry[:category_id] == category.id }
        spent = expense_total(category_entries)

        {
          id: category.id,
          label: category.name,
          color: category.color,
          monthly_limit: category.monthly_limit,
          spent: spent,
          utilization: utilization_for_limit(spent, category.monthly_limit),
          status: budget_status_for(spent, category.monthly_limit)
        }
      end

      uncategorized_spent = expense_total(expense_entries.select { |entry| entry[:category_id].nil? })
      if uncategorized_spent.positive?
        tracked_categories << {
          id: nil,
          label: UNCATEGORIZED_LABEL,
          color: "#94a3b8",
          monthly_limit: nil,
          spent: uncategorized_spent,
          utilization: nil,
          status: "needs_review"
        }
      end

      tracked_categories
    end

    def rankings
      {
        categories: grouped_ranking(expense_entries) { |entry| entry[:category_name] },
        merchants: grouped_ranking(expense_entries) { |entry| entry[:merchant_name].presence || entry[:title] }
      }
    end

    def recent_activity
      period_transactions
        .sort_by { |transaction| [ transaction.payment_date.to_date, transaction.created_at ] }
        .reverse
        .first(10)
        .map do |transaction|
          {
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.description,
            merchant_name: transaction.merchant_name,
            payment_date: transaction.payment_date,
            due_date: transaction.due_date,
            transaction_type: transaction.transaction_type,
            status: transaction.status,
            entry_state: transaction.entry_state,
            review_status: transaction.review_status,
            category: transaction.category&.name || UNCATEGORIZED_LABEL,
            payment_method: transaction.payment_method&.name
          }
        end
    end

    def grouped_ranking(entries)
      entries.each_with_object(Hash.new(0)) do |entry, groups|
        groups[yield(entry)] += entry[:amount].to_d
      end.sort_by { |_label, amount| -amount }
        .first(5)
        .map do |label, amount|
          {
            label: label.presence || UNCATEGORIZED_LABEL,
            amount: amount
          }
        end
    end

    def realized_income
      @realized_income ||= income_total(period_entries.select { |entry| entry[:entry_state] == "realized" })
    end

    def committed_income
      @committed_income ||= income_total(period_entries.select { |entry| entry[:entry_state] == "committed" })
    end

    def predicted_income
      @predicted_income ||= income_total(period_entries.select { |entry| entry[:entry_state] == "predicted" })
    end

    def realized_expenses
      @realized_expenses ||= expense_total(period_entries.select { |entry| entry[:entry_state] == "realized" })
    end

    def committed_expenses
      @committed_expenses ||= expense_total(period_entries.select { |entry| entry[:entry_state] == "committed" })
    end

    def predicted_expenses
      @predicted_expenses ||= expense_total(period_entries.select { |entry| entry[:entry_state] == "predicted" })
    end

    def total_income
      @total_income ||= income_total(period_entries)
    end

    def total_expenses
      @total_expenses ||= expense_total(period_entries)
    end

    def income_total(entries)
      entries.select { |entry| %w[income refund].include?(entry[:transaction_type]) }.sum { |entry| entry[:amount].to_d }
    end

    def expense_total(entries)
      entries.select { |entry| %w[expense].include?(entry[:transaction_type]) }.sum { |entry| entry[:amount].to_d }
    end

    def period_entries
      @period_entries ||= (actual_entries + predicted_recurrence_entries).sort_by { |entry| entry[:commitment_date] }
    end

    def expense_entries
      period_entries.select { |entry| entry[:transaction_type] == "expense" }
    end

    def actual_entries
      @actual_entries ||= period_transactions.map { |transaction| build_transaction_entry(transaction) }
    end

    def period_transactions
      @period_transactions ||= all_transactions.select { |transaction| transaction.period_bucket == bucket }
    end

    def predicted_recurrence_entries
      actual_recurrence_buckets = period_transactions.group_by(&:recurrence_id).transform_values do |transactions|
        transactions.map(&:period_bucket)
      end

      active_recurrences.flat_map do |recurrence|
        recurrence.occurrences_between(start_date.prev_month.prev_month.beginning_of_month, end_date).filter_map do |occurrence_date|
          next unless Finance::CommitmentRules.bucket_for_recurrence(recurrence, occurrence_date) == bucket
          next if actual_recurrence_buckets.fetch(recurrence.id, []).include?(bucket)

          build_recurrence_entry(recurrence, occurrence_date)
        end
      end
    end

    def all_transactions
      @all_transactions ||= user.transactions.kept
        .includes(:category, :installment_plan, :payment_method, :recurrence, :tags, :transaction_items)
        .to_a
    end

    def active_recurrences
      @active_recurrences ||= user.recurrences.active.includes(:category, :payment_method).to_a
    end

    def payment_methods
      @payment_methods ||= PaymentMethod.kept.where(user_id: [ user.id, nil ]).order(:kind, :name).to_a
    end

    def build_transaction_entry(transaction)
      {
        source_type: "transaction",
        source_id: transaction.id,
        transaction_type: transaction.transaction_type,
        title: transaction.description,
        merchant_name: transaction.merchant_name,
        amount: transaction.amount.to_d,
        entry_state: transaction.entry_state,
        review_status: transaction.review_status,
        commitment_date: transaction.commitment_date,
        category_id: transaction.category_id,
        category_name: transaction.category&.name || UNCATEGORIZED_LABEL,
        payment_method_id: transaction.payment_method_id,
        payment_method_name: transaction.payment_method&.name,
        payment_method_kind: transaction.payment_method&.kind,
        installment_position: transaction.installment_position,
        total_installments: transaction.installment_plan&.total_installments
      }
    end

    def build_recurrence_entry(recurrence, occurrence_date)
      {
        source_type: "recurrence",
        source_id: recurrence.id,
        transaction_type: "expense",
        title: recurrence.name,
        merchant_name: nil,
        amount: recurrence.amount.to_d,
        entry_state: "predicted",
        review_status: recurrence.review_status,
        commitment_date: Finance::CommitmentRules.commitment_date_for_recurrence(recurrence, occurrence_date),
        category_id: recurrence.category_id,
        category_name: recurrence.category&.name || UNCATEGORIZED_LABEL,
        payment_method_id: recurrence.payment_method_id,
        payment_method_name: recurrence.payment_method&.name,
        payment_method_kind: recurrence.payment_method&.kind,
        installment_position: nil,
        total_installments: nil
      }
    end

    def budget_status_for(spent, monthly_limit)
      return "untracked" if monthly_limit.blank?
      return "over_limit" if spent > monthly_limit
      return "attention" if spent >= monthly_limit * 0.85

      "healthy"
    end

    def utilization_for_limit(spent, monthly_limit)
      return nil if monthly_limit.blank? || monthly_limit.to_d.zero?

      ((spent.to_d / monthly_limit.to_d) * 100).round(1)
    end

    def utilization_for(payment_method, amount)
      return nil unless payment_method.credit_card? && payment_method.credit_limit.present? && payment_method.credit_limit.positive?

      ((amount.to_d / payment_method.credit_limit.to_d) * 100).round(1)
    end

    def remaining_limit_for(payment_method, amount)
      return nil unless payment_method.credit_card? && payment_method.credit_limit.present?

      payment_method.credit_limit.to_d - amount.to_d
    end

    def formatted_currency(value)
      format("%.2f", value)
    end
  end
end
