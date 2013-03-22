class AccountsController < ApplicationController
  
  def create
    @user = User.new(params[:user])
    Vulcain::Account.new(@user).create
  end
  
end
