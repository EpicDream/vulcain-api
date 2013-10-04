module RobotCore
  class Registration < RobotModule

    def initialize
      super
      set_dictionary(:REGISTER)
    end

    def run
      access_form
      login
      Action(:wait)
      
      Terminate(:account_creation_failed) and return if still_login_step?
      Address.new.fill_using(:REGISTER)

      phone
      birthdate
      password
      pseudonym
      options
      
      submit
      submit_options
      
      Terminate(:account_creation_failed) and return if fails? && !submit_with_new_pseudonym
      Message(:account_created, :next_step => 'renew login')
    end
    
    private
    
    def options
      [dictionary[:option]].flatten.each { |option| Action(:click_on, option) }
    end
    
    def fails?
      !Action(:wait_leave, :submit)
    end
    
    def password
      Action(:fill, :email_confirmation, with:account.login)
      Action(:fill, :password, with:account.password)
      Action(:fill, :password_confirmation, with:account.password)
    end
    
    def pseudonym n=0
      return unless dictionary[:pseudonym]
      pseudonym = account.login.match(/(.*?)@.*/).captures.first.gsub(/\.|_|-/, '')[0..9]
      pseudonym += n.to_s.rjust(2, "0")
      Action(:fill, :pseudonym, with:pseudonym)
    end
    
    def submit
      Action(:click_on, :cgu)
      MAction(:click_on, :submit)
      Action(:wait)
    end
    
    def submit_with_new_pseudonym
      return if !dictionary[:pseudonym] || !dictionary[:pseudonym_error_match]
      10.times do |n|
        node = Action(:find_element, :error)
        error = !!node && Action(:get_text, :error)
        if error =~ dictionary[:pseudonym_error_match]
          pseudonym(n + 1)
          submit
        else
          return !node
        end
      end
    end
    
    def submit_options
      if Action(:exists?, :address_option)
        MAction(:click_on, :address_option)
        MAction(:move_to_and_click_on, :submit)
      end
    end
    
    def access_form
      Action(:open_url, :base)
      Action(:open_url, :account)
      Action(:open_url, :register)
      Action(:click_on, :button_1)
      Action(:wait)
      Action(:click_on, :button_2)
      Action(:wait_for, [:submit_login, :submit])
      Action(:wait)
    end
    
    def still_login_step?
      !dictionary[:submit_login].nil? && Action(:exists?, :submit_login)
    end
    
    def login
      Action(:fill, :email, with:account.login)
      Action(:fill, :email_confirmation, with:account.login)
      Action(:fill, :password, with:account.password)
      Action(:fill, :password_confirmation, with:account.password)
      Action(:click_on, :submit_login)
    end
    
    def phone
      Action(:fill, :mobile_phone, with:user.address.mobile_phone)
      Action(:fill, :land_phone, with:user.address.land_phone)
    end
    
    def birthdate
      if dictionary[:birthdate]
        MAction(:fill, :birthdate, with:BIRTHDATE_AS_STRING.(user.birthdate))
      end
      if dictionary[:birthdate_day]
        zero_fill?
        MAction(:select_option, :birthdate_day, value:user.birthdate.day)
        MAction(:select_option, :birthdate_month, value:user.birthdate.month)
        MAction(:select_option, :birthdate_year, value:user.birthdate.year)
      end
      Action(:fill, :birth_department, with:user.address.zip[0..1])
    end
    
    def zero_fill?
      options = Action(:options_of_select, :birthdate_day)
      if options.keys.include?("01")
        user.birthdate.day = user.birthdate.day.to_s.rjust(2, "0")
        user.birthdate.month = user.birthdate.month.to_s.rjust(2, "0")
      end
    end
    
  end
end