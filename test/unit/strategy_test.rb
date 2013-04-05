require 'test_helper'

class StrategyTest < ActiveSupport::TestCase
  
  setup do
    @context = {}
  end
  
  teardown do
    `killall Google\\ Chrome` #osx
  end
  
  test "it should respond to open_url, fill input, select option, click_on : radio_button, links with label" do
    driver = Driver.new
    strategy = Strategy.new(@context, driver) do
      step(1) do
        open_url "http://www.rueducommerce.fr/home/index.htm"
        click_on '//*[@id="linkJsAccount"]/div/div[2]/span[1]'
        fill '//*[@id="loginNewAccEmail"]', with:'madmax_031@yopmail.com'
        click_on '//*[@id="loginNewAccSubmit"]'
        select_option '//*[@id="content"]/form/div/div[2]/div/div[7]/select[1]', "12"
        click_on '//*[@id="content"]/form/div/div[3]/div/div[3]/input[1]'
      end
    end
    assert strategy.run
    driver.quit
    
  end
  
end