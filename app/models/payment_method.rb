class PaymentMethod < ApplicationRecord
  include Auditable

  belongs_to :user, optional: true
  has_many :transactions, dependent: :restrict_with_error
  has_many :recurrences, dependent: :restrict_with_error
  has_many :installment_plans, dependent: :restrict_with_error

  enum :identifier, { unknown: 0, credit_card: 1, debit_card: 2, cash: 3, pix: 4, boleto: 5 }, prefix: true
  enum :kind, { account: "account", credit_card: "credit_card", instant: "instant" }

  validates :name, presence: true
  validates :locale, presence: true
  validates :display_color, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }
  validates :credit_limit, numericality: { greater_than_or_equal_to: 0 }, if: :credit_card?
  validates :closing_day, inclusion: { in: 1..31 }, if: :credit_card?
  validates :due_day, inclusion: { in: 1..31 }, if: :credit_card?

  before_validation :normalize_kind
  before_validation :apply_defaults

  scope :active, -> { kept.where(is_active: true) }

  def review_status
    return "inactive" unless is_active?
    return "needs_card_config" if credit_card? && !card_schedule_complete?

    "ok"
  end

  def card_schedule_complete?
    return true unless credit_card?

    closing_day.present? && due_day.present? && credit_limit.present?
  end

  private

  def apply_defaults
    self.locale = "pt-BR" if locale.blank?
    self.display_color = default_color if display_color.blank?
    self.is_active = true if is_active.nil?
  end

  def normalize_kind
    return if kind.present?

    self.kind =
      case identifier
      when "credit_card"
        "credit_card"
      when "pix", "cash", "boleto"
        "instant"
      else
        "account"
      end
  end

  def default_color
    case kind
    when "credit_card"
      "#1d4ed8"
    when "instant"
      "#0f766e"
    else
      "#6d28d9"
    end
  end
end
