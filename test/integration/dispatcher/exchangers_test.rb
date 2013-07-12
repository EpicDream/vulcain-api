require 'test_helper'

class ExchangersTest <  ActiveSupport::TestCase
  RDC_URL = "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr"
  
  setup do
  end
  
  test "synchrone request return" do
    request = {vendor:"RueDuCommerce", url:RDC_URL}.to_json
    response = Dispatcher::AMQPController.synchrone_request(request)
    assert response["status"]
  end
  
end