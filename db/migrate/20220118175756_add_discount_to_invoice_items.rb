class AddDiscountToInvoiceItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoice_items, :bulk_discount, foreign_key: true
  end
end
