class Admin::InvoicesController < ApplicationController
  def index
    @invoices = Invoice.all
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def update
    invoice = Invoice.find(params[:id])
    if invoice.update(invoice_params)
      redirect_to admin_invoices_path(:id)
      flash[:alert] = "Invoice #{invoice.id} has been updated"
    end
    if invoice.completed?
      invoice.invoice_items.each do |inv_itm|
        inv_itm.update(bulk_discount_id: inv_itm.discount.id) if inv_itm.discount.present?
      end
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:status)
  end
end
