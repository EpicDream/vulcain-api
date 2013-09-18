module RobotCore
  class Login < RobotModule

    def initialize
      super
      set_dictionary(:LOGIN)
    end

    def run
      access_form
      2.times { decaptchatize }
      login
      submit
      raise RobotCore::VulcainError.new(:login_failed) if fails?
      Message(:logged, :next_step => 'empty cart')
    end
    
    def renew
      robot.run_step('logout')
      robot.open_url robot.order.products[0].url
      run
    end
    
    def relog
      Action(:fill, :email, with:account.login, check:true)
      Action(:fill, :password, with:account.password, check:true)
      Action(:click_on, :submit, check:true)
    end
    
    private
    
    def fails?
      Action(:exists?, :submit)
    end
    
    def resolve_captcha image_url
      client = DeathByCaptcha.http_client('ericlarch', 'yolain$1')
      response = client.decode image_url
      response['text']
    end
    
    def decaptchatize
      return unless Action(:exists?, :captcha)
      Action(:wait)
      element = Action(:find_element, :captcha)
      text = resolve_captcha element.attribute('src')
      Action(:fill, :captcha_input, with:text)
      Action(:click_on, :captcha_submit, check:true)
    end
    
    def access_form
      Action(:open_url, :login)
      Action(:click_on, :popup)
      Action(:click_on, :link, check:true)
    end
    
    def submit
      Action(:click_on, :submit)
    end
    
    def login
      Action(:fill, :email, with:account.login)
      Action(:fill, :password, with:account.password)
    end
    
  end
end

