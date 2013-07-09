module RobotCore
  class Registration
    BIRTHDATE_AS_STRING = lambda do |birthdate|
      [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
    end
    
    attr_reader :user, :account, :vendor, :robot, :deviances
    
    def initialize robot, deviances={}
      @robot = robot
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
      @deviances = deviances
    end
    
    def run
      access_form
      login

      if still_login_step?
        robot.terminate_on_error(:account_creation_failed)
        return
      end
      
      gender
      birthdate
      address
      submit
      submit_options
      
      if fails? 
        robot.terminate_on_error :account_creation_failed
      else
        robot.message :account_created, :next_step => 'renew login'
      end
    end
    
    private
    
    def fails?
      !robot.wait_leave(vendor::REGISTER[:submit])
    end
    
    def submit
      robot.click_on vendor::REGISTER[:cgu], check:true
      robot.click_on vendor::REGISTER[:submit]
      robot.wait_ajax
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
    
    def gender
      if robot.exists? vendor::REGISTER[:gender]
        value = case user.gender
        when 0 then vendor::REGISTER[:mister]
        when 1 then vendor::REGISTER[:madam]
        when 2 then vendor::REGISTER[:miss]
        end
        robot.select_option vendor::REGISTER[:gender], value
      elsif robot.exists? vendor::REGISTER[:mister]
        robot.click_on_radio user.gender, { 0 => vendor::REGISTER[:mister], 1 =>  vendor::REGISTER[:madam], 2 =>  vendor::REGISTER[:miss] }
      end
    end
    
    def birthdate
      if vendor::REGISTER[:birthdate]
        robot.fill vendor::REGISTER[:birthdate], with:BIRTHDATE_AS_STRING.(user.birthdate)
      end
      if vendor::REGISTER[:birthdate_day]
        robot.select_option vendor::REGISTER[:birthdate_day], user.birthdate.day.to_s.rjust(2, "0")
        robot.select_option vendor::REGISTER[:birthdate_month], user.birthdate.month.to_s.rjust(2, "0")
        robot.select_option vendor::REGISTER[:birthdate_year], user.birthdate.year.to_s.rjust(2, "0")
      end
    end
    
    def address
      unless deviances[:zip]
        robot.fill vendor::REGISTER[:zip], with:user.address.zip, check:true
      else
        deviances[:zip].call
      end

      properties = user.address.marshal_dump.keys
      properties.each do |property|
        robot.fill vendor::REGISTER[property], with:user.address.send(property), check:true
      end

      if robot.exists? vendor::REGISTER[:address_type]
        user.address.address_1 =~ /(\d+)[\s,]+(.*?)\s+(.*)/
        robot.fill vendor::REGISTER[:address_number], with:$1, check:true

        begin
          options = options_of_select(vendor::REGISTER[:address_type])
          option = options.detect { |value, text|  text.downcase.strip == $2.downcase.strip}
          robot.select_option(vendor::REGISTER[:address_type], option[0])
        rescue
          robot.fill vendor::REGISTER[:address_track], with:"#{$2} #{$3}", check:true
        else
          robot.fill vendor::REGISTER[:address_track], with:$3, check:true
        end

      end

      unless deviances[:city]
        robot.fill vendor::REGISTER[:city], with:user.address.city, check:true
      else
        deviances[:city].call
      end

      robot.fill vendor::REGISTER[:address_identifier], with:user.last_name, check:true
    end
    
  end
end