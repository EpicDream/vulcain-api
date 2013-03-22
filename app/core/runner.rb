# -*- encoding : utf-8 -*-
require_relative 'shopelia'
require_relative 'rue_du_commerce'
require 'date'

User = Struct.new(:firstname, :lastname, :email, :address, :city, :postalcode, :birthday)
CB = Struct.new(:number, :month_expire, :year_expire, :crypto)
user = User.new("Mad", "Max", "madmax_10@yopmail.com", "12 rue des Lilas", "Paris", "75002", Date.parse("1985-10-10"))
cb = CB.new("212918291291", "01", "16", "678")
# account = Shopelia::Account.new(user)
# account.class.class_eval { include(RueDuCommerce) }
# account.create

login = Shopelia::Login.new(user)
login.class.class_eval { include(RueDuCommerce) }
login.create

order = Shopelia::Order.new("http://m.rueducommerce.fr/fiche-produit/Galaxytab2-P5110-16Go-Blanc-OP", cb)
order.class.class_eval { include(RueDuCommerce) }
order.create
