require_relative 'vulcain'
require_strategy 'rue_du_commerce'
require_strategy 'fnac'
USER_ACCOUNT_PASSWORD = "shopelia2013"

User = Struct.new(:firstname, :lastname, :email, :address, :city, :postalcode, :birthday, :gender, :telephone)
Order = Struct.new(:product_url, :card_number, :card_crypto, :expire_month, :expire_year, :holder, :account_password)

user = User.new("Mad", "Max", "alfred01@yopmail.com", "12 rue des Lilas", "Paris", "75019", Date.parse("1985-10-01"), 0, "0650151515")

order = Order.new("http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm", "87989898", "345", "01", "16", "ROGER RABBIT", USER_ACCOUNT_PASSWORD)
context = {user:user, order:order}
# RueDuCommerce.new(driver, context).account.run
RueDuCommerce.new(context).login.run
# RueDuCommerce.new(driver, context).order.run

order = Order.new("http://musique.fnac.com/a5549347/Jean-Louis-Murat-Toboggan-Edition-limitee-CD-album#bl=MUVari%c3%a9t%c3%a9-fran%c3%a7aiseBLO2", "87989898", "345", "01", "2016", "ROGER RABBIT", USER_ACCOUNT_PASSWORD)
context = {user:user, order:order}
# Fnac.new(driver, context).account.run
# Fnac.new(driver, context).login.run
# Fnac.new(driver, context).order.run

#driver.quit