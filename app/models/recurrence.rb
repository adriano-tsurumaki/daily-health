class Recurrence < ApplicationRecord
  include Auditable

  belongs_to :user, optional: true
  belongs_to :category, optional: true
  belongs_to :payment_method
  has_many :transactions, dependent: :nullify

  enum :frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }

  validates :name, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :recurrence_interval, numericality: { greater_than: 0 }
  validates :next_due_date, presence: true

  scope :active, -> { kept.where(is_active: true) }

  def review_status
    return "broken_schedule" if end_date.present? && next_due_date.present? && next_due_date > end_date
    return "needs_category" if category_id.nil?
    return "needs_instrument_review" if payment_method.review_status != "ok"

    "ok"
  end

  def occurrences_between(range_start, range_end)
    return [] unless is_active?
    return [] if next_due_date.blank?

    cursor = next_due_date.to_date
    limit_date = end_date&.to_date

    while cursor < range_start.to_date
      cursor = advance_occurrence(cursor)
      break if limit_date.present? && cursor > limit_date
    end

    occurrences = []
    while cursor <= range_end.to_date
      break if limit_date.present? && cursor > limit_date

      occurrences << cursor
      cursor = advance_occurrence(cursor)
    end

    occurrences
  end

  def projected_total(months)
    projection_start = Date.current.beginning_of_month
    projection_end = projection_start >> months
    occurrences_between(projection_start, projection_end.prev_day).count * amount
  end

  private

  def advance_occurrence(date)
    case frequency
    when "daily"
      date + recurrence_interval.days
    when "weekly"
      date + recurrence_interval.weeks
    when "monthly"
      date >> recurrence_interval
    when "yearly"
      date >> (recurrence_interval * 12)
    else
      date
    end
  end
end
