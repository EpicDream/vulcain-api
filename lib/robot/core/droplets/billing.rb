module RobotCore
  class Billing < RobotModule
    @@shipping = nil
    
    def initialize
      super
      set_dictionary(:BILL)
    end
    
    def build
      return unless build?
      shipping, total = [:shipping, :total].map { |key| Price(key) }
      info = Action(:get_text, :info)
      shipping ||= @@shipping
      shipping ||= shipping_from_products

      robot.billing = { shipping:shipping, total:total, shipping_info:info}
    end
    
    def shipping_from_dictionary dico
      @@shipping = Price(dico[:shipping])
    end
    
    private
    
    def shipping_from_products
      products.inject(0) { |total, product| total += product["price_delivery"].to_f }
    end
    
    def build?
      Action(:wait)
      Action(:exists?, :total) && !robot.billing
    end
    
  end
end

