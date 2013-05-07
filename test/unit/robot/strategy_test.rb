require 'test_helper'

class RobotTest < ActiveSupport::TestCase
  
  setup do
    @context = {'account' => {'email' => 'madmax_1181@yopmail.com', 'password' => 'shopelia'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'token' => 'dzjdzj2102901'}}
  end
  
  teardown do
  end
  
  test "it should respond to open_url, fill input, select option, click_on : radio_button, links with label" do
    text = nil
    robot = Robot.new(@context) do
      step('test') do
        open_url "http://www.rueducommerce.fr/home/index.htm"
        click_on '//*[@id="ox-is-skip"]/img'
        click_on '//*[@id="linkJsAccount"]/div/div[2]/span[1]'
        fill '//*[@id="loginNewAccEmail"]', with:'madmax_031@yopmail.com'
        click_on '//*[@id="loginNewAccSubmit"]'
        select_option '//*[@id="content"]/form/div/div[2]/div/div[7]/select[1]', "12"
        click_on '//*[@id="content"]/form/div/div[3]/div/div[3]/input[1]'
        text = get_text '//*[@id="content"]/form/div/div[3]/div/p[2]'
      end
    end
    robot.exchanger = stub()
    robot.self_exchanger = robot.exchanger
    robot.logging_exchanger = robot.exchanger
    robot.exchanger.expects(:publish).times(1)
    
    assert robot.run_step('test')
    assert_equal "Adresse de facturation", text
    robot.driver.quit
  end
  
end