module RobotCore
  class Registration < RobotModule

    def run
      access_form
      login

      if still_login_step?
        robot.terminate_on_error(:account_creation_failed)
        return
      end
      
      Address.new.fill_using(vendor::REGISTER)
      
      phone
      birthdate
      password
      pseudonym
      options
      
      submit
      submit_options
      
      if fails? && !submit_with_new_pseudonym
        robot.terminate_on_error :account_creation_failed
      else
        robot.message :account_created, :next_step => 'renew login'
      end
    end
    
    private
    
    def options
      [vendor::REGISTER[:option]].flatten.each { |option|
        robot.click_on option, check:true
      }
    end
    
    def fails?
      !robot.wait_leave(vendor::REGISTER[:submit])
    end
    
    def password
      robot.fill vendor::REGISTER[:email_confirmation], with:account.login, check:true
      robot.fill vendor::REGISTER[:password], with:account.password, check:true
      robot.fill vendor::REGISTER[:password_confirmation], with:account.password, check:true
    end
    
    def pseudonym n=0
      return unless vendor::REGISTER[:pseudonym]
      pseudonym = account.login.match(/(.*?)@.*/).captures.first.gsub(/\.|_|-/, '')[0..9]
      pseudonym += n.to_s.rjust(2, "0")
      robot.fill vendor::REGISTER[:pseudonym], with:pseudonym, check:true
    end
    
    def submit
      robot.click_on vendor::REGISTER[:cgu], check:true
      robot.click_on vendor::REGISTER[:submit]
      robot.wait_ajax
    end
    
    def submit_with_new_pseudonym
      return unless vendor::REGISTER[:pseudonym]
      10.times do |n|
        node = robot.find_element vendor::REGISTER[:error], nowait:true
        error = !!node && robot.get_text(vendor::REGISTER[:error])
        if error =~ vendor::REGISTER[:pseudonym_error_match]
          pseudonym(n + 1)
          submit
        else
          return !node
        end
      end
    end
    
    def submit_options
      if robot.exists? vendor::REGISTER[:address_option]
        robot.click_on vendor::REGISTER[:address_option]
        robot.move_to_and_click_on vendor::REGISTER[:submit]
      end
    end
    
    def access_form
      robot.open_url vendor::URLS[:base]
      robot.open_url vendor::URLS[:account]
      robot.open_url(vendor::URLS[:register]) || robot.click_on(vendor::REGISTER[:new_account])
      robot.wait_for([vendor::REGISTER[:submit_login], vendor::REGISTER[:submit]])
    end
    
    def still_login_step?
      !vendor::REGISTER[:submit_login].nil? && robot.exists?(vendor::REGISTER[:submit_login])
    end
    
    def login
      robot.fill vendor::REGISTER[:email], with:account.login, check:true
      robot.fill vendor::REGISTER[:email_confirmation], with:account.login, check:true
      robot.fill vendor::REGISTER[:password], with:account.password, check:true
      robot.fill vendor::REGISTER[:password_confirmation], with:account.password, check:true
      robot.click_on vendor::REGISTER[:submit_login], check:true
    end
    
    def phone
      robot.fill vendor::REGISTER[:mobile_phone], with:user.address.mobile_phone, check:true
      robot.fill vendor::REGISTER[:land_phone], with:user.address.land_phone, check:true
    end
    
    def birthdate
      if vendor::REGISTER[:birthdate]
        robot.fill vendor::REGISTER[:birthdate], with:BIRTHDATE_AS_STRING.(user.birthdate)
      end
      if vendor::REGISTER[:birthdate_day]
        zero_fill?
        robot.select_option vendor::REGISTER[:birthdate_day], value:user.birthdate.day
        robot.select_option vendor::REGISTER[:birthdate_month], value:user.birthdate.month
        robot.select_option vendor::REGISTER[:birthdate_year], value:user.birthdate.year
      end
      robot.fill vendor::REGISTER[:birth_department], with:user.address.zip[0..1], check:true
    end
    
    def zero_fill?
      options = robot.options_of_select(vendor::REGISTER[:birthdate_day])
      if options.keys.include?("01")
        user.birthdate.day = user.birthdate.day.to_s.rjust(2, "0")
        user.birthdate.month = user.birthdate.month.to_s.rjust(2, "0")
      end
    end
    
  end
end