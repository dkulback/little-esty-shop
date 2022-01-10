class MerchantItemsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @items = @merchant.items
  end

  def show
    @item = Item.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
    flash.keep
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @item = Item.find(params[:id])
  end

  def update
    item = Item.find(params[:id])
    if params[:status].present?
      item.update(status: params[:status])
      redirect_to merchant_items_url
    else
      item.update(item_params)
      flash[:success] = item.name + ' was successfully updated.'
    redirect_to merchant_item_path(params[:merchant_id], item)
    end
  end

  private
    def item_params
      params.require(:item).permit(:name, :description, :unit_price)
    end
end