module RobotCore
  class Login
    
    attr_reader :account, :vendor, :robot
    
    def initialize robot, deviances={}
      @robot = robot
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
    end

    def run
      access_form
      2.times { decaptchatize }
      login
      submit
      
      if fails?
        robot.terminate_on_error :login_failed
      else
        robot.message :logged, :next_step => 'empty cart'
      end
    end
    
    private
    
    def fails?
      robot.exists? vendor::LOGIN[:submit]
    end
    
    def resolve_captcha image_url
      client = DeathByCaptcha.http_client('ericlarch', 'yolain$1')
      response = client.decode image_url
      response['text']
    end
    
    def decaptchatize
      return unless vendor::LOGIN[:captcha]
      robot.wait_ajax
      if robot.exists? vendor::LOGIN[:captcha]
        element = robot.find_element vendor::LOGIN[:captcha]
        text = resolve_captcha element.attribute('src')
        robot.fill vendor::LOGIN[:captcha_input], with:text
      end
      robot.click_on vendor::LOGIN[:captcha_submit], check:true
    end
    
    def access_form
      robot.open_url vendor::URLS[:login]
      robot.click_on vendor::LOGIN[:link], check:true
    end
    
    def submit
      robot.click_on vendor::LOGIN[:submit]
    end
    
    def login
      robot.fill vendor::LOGIN[:email], with:account.login
      robot.fill vendor::LOGIN[:password], with:account.password
    end
    
  end
end

