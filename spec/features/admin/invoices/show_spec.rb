require 'rails_helper'

RSpec.describe 'Admin Invoice Show Page' do
  before(:each) do
    @merch_1 = Merchant.create!(name: 'Shop Here')
    @discount = @merch_1.bulk_discounts.create!(title: 'A', qty_threshold: 1, percentage: 10)
    @item_1 = Item.create!(name: 'jumprope', description: 'Pink and sparkly.', unit_price: 600,
                           merchant_id: @merch_1.id.to_s)
    @item_2 = Item.create!(name: 'hula hoop', description: 'Get your groove on!', unit_price: 700,
                           merchant_id: @merch_1.id.to_s)

    @cust_1 = Customer.create!(first_name: 'Hannah', last_name: 'Warner')

    @invoice_1 = Invoice.create!(customer_id: @cust_1.id.to_s, status: 1)
    @invoice_2 = Invoice.create!(customer_id: @cust_1.id.to_s, status: 1)
    @invoice_3 = Invoice.create!(customer_id: @cust_1.id.to_s, status: 1)

    @invoice_item_1 = InvoiceItem.create!(invoice_id: @invoice_1.id.to_s, item_id: @item_1.id.to_s, status: 2,
                                          quantity: 1, unit_price: 600)
    @invoice_item_2 = InvoiceItem.create!(invoice_id: @invoice_2.id.to_s, item_id: @item_2.id.to_s, status: 2,
                                          quantity: 1, unit_price: 700)
    @invoice_item_3 = InvoiceItem.create!(invoice_id: @invoice_3.id.to_s, item_id: @item_2.id.to_s, status: 2,
                                          quantity: 1, unit_price: 700)
    @invoice_item_4 = InvoiceItem.create!(invoice_id: @invoice_3.id.to_s, item_id: @item_2.id.to_s, status: 2,
                                          quantity: 2, unit_price: 700)
  end

  it 'shows customer and status information for the invoice' do
    visit "/admin/invoices/#{@invoice_1.id}"

    expect(page).to have_content("Invoice ID: #{@invoice_1.id}")
    expect(page).to have_content("Invoice Status: #{@invoice_1.status}")
    expect(page).to have_content(@invoice_1.created_at.strftime('%A, %B %d, %Y'))
    expect(page).to have_content(@cust_1.first_name)
    expect(page).to have_content(@cust_1.last_name)
  end

  it 'shows Item information for the the show page' do
    visit "/admin/invoices/#{@invoice_1.id}"

    within '.invoice' do
      expect(page).to have_content(@item_1.name)
      expect(page).to_not have_content(@item_2.name)
      expect(page).to have_content(@invoice_item_1.quantity)
      expect(page).to have_content(@invoice_item_1.unit_price)
      expect(page).to_not have_content(@invoice_item_3.unit_price)
      expect(page).to have_content(@invoice_item_1.status)
    end
  end

  it 'shows total revenue for generated from an invoice' do
    visit "/admin/invoices/#{@invoice_1.id}"

    within '.total_revenue' do
      expect(page).to have_content("Total Revenue: #{(@invoice_1.total_revenue / 100).to_s.prepend('$').concat('.00')}")
    end
  end

  it 'uses a select field to update invoice status' do
    visit "/admin/invoices/#{@invoice_1.id}"

    expect(page).to have_content(@invoice_1.status)
    select 'completed', from: 'Status'
    click_button 'Update Status'
    expect(current_path).to eq(admin_invoices_path(:id))
    expect(@invoice_1.status).to eq('completed')
  end
  it 'updates invoice_items if invoice had bulk_discounts attached to them' do
    visit admin_invoice_path(@invoice_1)
    within '.status' do
      select 'completed', from: 'Status'
      click_button 'Update Status'
    end
    @invoice_item_1.reload

    expect(@invoice_item_1.bulk_discount_id).to eq(@discount.id)
  end
  it 'shows the total discounted revenue' do
    visit admin_invoice_path(@invoice_1)

    within '.discounted-rev' do
      expect(page).to have_content("Discounted Total Revenue: #{(@invoice_1.discounted_total_rev / 100).to_s.prepend('$').concat('.00')}")
    end
  end
end
