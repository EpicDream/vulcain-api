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
      run
    end
    
    def relog
      Action(:fill, :email, with:account.login)
      Action(:fill, :password, with:account.password)
      Action(:click_on, :submit)
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
      element = MAction(:find_element, :captcha)
      text = resolve_captcha element.attribute('src')
      MAction(:fill, :captcha_input, with:text)
      Action(:click_on, :captcha_submit)
    end
    
    def access_form
      Action(:open_url, :login)
      Action(:click_on, :popup)
      Action(:click_on, :link)
    end
    
    def submit
      MAction(:click_on, :submit)
    end
    
    def login
      MAction(:fill, :email, with:account.login)
      MAction(:fill, :password, with:account.password)
    end
    
  end
end

