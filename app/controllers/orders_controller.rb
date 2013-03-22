class OrdersController < ApplicationController
  
  def create
    @user = User.new(params[:user])
    @cb = CreditCard.new(params[:cb])
    
    Vulcain::Login.new(@user).create
    Vulcain::Order.new(params[:product_url], @cb).create
  end
  
end
