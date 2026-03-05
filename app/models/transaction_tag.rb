class TransactionTag < ApplicationRecord
  self.primary_key = [ :transaction_id, :tag_id ]

  belongs_to :financial_transaction, class_name: "Transaction", foreign_key: :transaction_id
  belongs_to :tag
end
