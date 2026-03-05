class Api::V1::DashboardController < Api::BaseController
  # GET /api/v1/dashboard
  def show
    month = (params[:month] || Date.current.month).to_i
    year = (params[:year] || Date.current.year).to_i
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    transactions = current_user.transactions.kept.where(payment_date: start_date..end_date)

    total_income = transactions.income.sum(:amount)
    total_expense = transactions.expense.sum(:amount)

    recent = transactions
      .includes(:payment_method, :category, :tags)
      .order(payment_date: :desc)
      .limit(10)

    render json: {
      month: month,
      year: year,
      total_income: total_income,
      total_expense: total_expense,
      balance: total_income - total_expense,
      recent_transactions: recent.map { |t| summary_json(t) }
    }
  end

  private

  def summary_json(transaction)
    {
      id: transaction.id,
      amount: transaction.amount,
      payment_date: transaction.payment_date,
      transaction_type: transaction.transaction_type,
      status: transaction.status,
      category: transaction.category&.name,
      payment_method: transaction.payment_method&.name
    }
  end
end
