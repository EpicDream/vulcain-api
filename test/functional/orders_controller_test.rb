require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  
  setup do
    @user = {firstname:"Mad", lastname:"Max", email:"madmax_10@yopmail.com", address:"12 rue des Lilas", 
      city:"Paris", postalcode: "75002", birthday:"1985-01-01" }
    @cb = {number:"212918291291", month_expire:"01", year_expire:"16", crypto:"678"}
    @product_url = "http://m.rueducommerce.fr/fiche-produit/Galaxytab2-P5110-16Go-Blanc-OP"
  end
  
  test "create order" do
    post :create, user:@user, cb:@cb, product_url:@product_url
    
    assert_response :success
  end
  
  # @user = User.new({firstname:"Mad", lastname:"Max", email:"madmax_10@yopmail.com", address:"12 rue des Lilas", city:"Paris", postalcode: "75002", birthday:"1985-01-01" })
  # @cb = CreditCard.new({number:"212918291291", month_expire:"01", year_expire:"16", crypto:"678"})
  
end
