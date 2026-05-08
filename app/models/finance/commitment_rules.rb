module Finance
  module CommitmentRules
    module_function

    def bucket_for_transaction(transaction)
      bucket_for_date(commitment_date_for_transaction(transaction))
    end

    def bucket_for_recurrence(recurrence, occurrence_date)
      bucket_for_date(commitment_date_for_recurrence(recurrence, occurrence_date))
    end

    def commitment_date_for_transaction(transaction)
      base_date = transaction.due_date || transaction.payment_date
      commitment_date_for_payment_method(transaction.payment_method, base_date)
    end

    def commitment_date_for_recurrence(recurrence, occurrence_date)
      commitment_date_for_payment_method(recurrence.payment_method, occurrence_date)
    end

    def commitment_date_for_payment_method(payment_method, raw_date)
      return nil if raw_date.blank?

      base_date = raw_date.to_date
      if payment_method&.credit_card? && payment_method.card_schedule_complete?
        credit_card_due_date(payment_method, base_date)
      else
        base_date
      end
    end

    def credit_card_due_date(payment_method, charge_date)
      charge_date = charge_date.to_date
      current_month_closing = clamped_date(charge_date.year, charge_date.month, payment_method.closing_day)
      invoice_closing =
        if charge_date <= current_month_closing
          current_month_closing
        else
          next_month = charge_date.next_month
          clamped_date(next_month.year, next_month.month, payment_method.closing_day)
        end

      same_month_due = clamped_date(invoice_closing.year, invoice_closing.month, payment_method.due_day)
      return same_month_due if same_month_due > invoice_closing

      next_month = invoice_closing.next_month
      clamped_date(next_month.year, next_month.month, payment_method.due_day)
    end

    def bucket_for_date(raw_date)
      return nil if raw_date.blank?

      raw_date.to_date.strftime("%Y-%m")
    end

    def clamped_date(year, month, day)
      Date.new(year, month, [ day.to_i, Time.days_in_month(month, year) ].min)
    end
  end
end
