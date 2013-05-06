# encoding: utf-8

require 'test_helper'

class Plugin::IRobotTest < ActiveSupport::TestCase
  HTML_PAGE_URL = "file://"+Rails.root.to_s+"/test/data/fake_webpage_for_robots.html"

  def robot
    return @@robot if self.class.class_variable_defined?(:@@robot)
    context = {'account' => {'email' => 'madmax_1181@yopmail.com', 'password' => 'shopelia'},
              'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'token' => 'dzjdzj2102901'}}

    
    @@robot = Plugin::IRobot.new(context) {}
    @@robot.exchanger = stub()
    @@robot.self_exchanger = @@robot.exchanger
    @@robot.logging_exchanger = @@robot.exchanger
    return @@robot
  end

  test "a pl_open_url" do
    robot.pl_open_url HTML_PAGE_URL
    assert robot.pl_driver.title == "TEST PAGE"
  end

  test "input" do
    # XPATH DIRECT
    e = robot.input("//form/label[1]/input", "text")
    assert_not_nil e

    # XPATH LABEL FOR
    e = robot.input("//form/label[2]", "text")
    assert_not_nil e

    # XPATH LABEL IN
    e = robot.input("//form/label[1]", "text")
    assert_not_nil e

    # XPATH INSIDE
    e = robot.input("//form/span[1]", "text")
    assert_not_nil e

    # XPATH DIRECTrob
    e = robot.input("//form/label[1]/input", "radio")
    assert_nil e

    # XPATH LABEL FOR
    e = robot.input("//form/label[2]", "radio")
    assert_nil e

    # XPATH LABEL IN
    e = robot.input("//form/label[1]", "radio")
    assert_nil e

    # XPATH INSIDE
    e = robot.input("//form/span[1]", "radio")
    assert_nil e
  end

  test "inputs" do
    e = robot.inputs("//form/span[@id='radiosSpan']", "radio")
    assert ! e.empty?

    e = robot.inputs("//form/span[@id='radiosSpan']", "text")
    assert e.empty?

    e = robot.inputs("//span[@id='id']", "radio")
    assert e.empty?
  end

  test "pl_click_on" do
    assert_not_match /\#link1$/, robot.current_url
    assert_raise Plugin::IRobot::NoSuchElementError do
      robot.pl_click_on("//div[@class='uneclass']")
    end
    # Direct a
    robot.pl_click_on("//div[@class='uneclass']//a[@class='classa1']")
    assert_match /\#link1$/, robot.current_url
    
    # A dans span
    robot.pl_click_on("//div[@class='uneclass']//span")
    assert_match /\#link2$/, robot.current_url
    
    # A parent
    robot.pl_click_on("//span[@id='ida3']/b")
    assert_match /\#link3$/, robot.current_url
  end

  test "pl_click_on_while" do
    elems = robot.find("//div[@id='panierHTML']//a")
    assert_equal 3, elems.size
    
    robot.pl_click_on_while("//div[@id='panierHTML']")
    elems = robot.find("//div[@id='panierHTML']//a")
    assert_equal 0, elems.size
  end

  test "pl_click_on_each" do
    elems = robot.find("//div[@id='panierJavascript']//a")
    assert_equal 3, elems.size

    robot.pl_click_on_each("//div[@id='panierJavascript']")
    elems = robot.find("//div[@id='panierJavascript']//a")
    assert_equal 0, elems.size
  end

  test "pl_fill_text" do
    e = robot.pl_driver.find_element(xpath: "//form/label[1]/input")
    assert e["value"].blank?
    robot.pl_fill_text("//form/label[1]", "toto")
    assert_equal "toto", e["value"]
  end

  test "pl_select_option" do
    e = robot.pl_driver.find_element(xpath: "//form/select[1]")
    assert e["value"].blank?
    robot.pl_select_option("//form/select[1]", "M")
    assert_equal "M", e.value

    robot.pl_select_option("//form/label[5]", "MME")
    assert_equal "MME", e.value

    robot.pl_select_option("//form/select[1]", "Mademoiselle")
    assert_equal "MLLE", e.value

    e = robot.pl_driver.find_element(xpath: "//select[@id='genreVal']")
    robot.pl_select_option("//div[@id='selects']/select[1]", "MME")
    assert_equal "MME", e.value
    robot.pl_select_option("//div[@id='selects']/select[1]", /^(mr?\.?|monsieur|mister|homme)$/i)
    assert_equal "M", e.value
    robot.pl_select_option("//div[@id='selects']/select[1]", ["femme", "Mademoiselle", "mademll", "Mlle", "mlle", "MLLE"])
    assert_equal "MLLE", e.value

    e = robot.pl_driver.find_element(xpath: "//select[@id='genreText']")
    robot.pl_select_option("//div[@id='selects']//label//span[@class='classGT']", "Monsieur")
    assert_equal "10", e.value
    
    e = robot.pl_driver.find_element(xpath: "//select[@id='dateVal']")
    robot.pl_select_option("//div[@id='selects']/label/span[@class='classDV']", 2)
    assert_equal "02", e.value
    robot.pl_select_option("//div[@id='selects']/label/span[@class='classDV']", 1)
    assert_equal "01", e.value
    robot.pl_select_option("//div[@id='selects']/label/span[@class='classDV']", 10)
    assert_equal "10", e.value

    e = robot.pl_driver.find_element(xpath: "//select[@id='dateText']")
    robot.pl_select_option("//div[@id='selects']/div[@class='classDT']", 2)
    assert_equal "02", e.value
    robot.pl_select_option("//div[@id='selects']/div[@class='classDT']", 1)
    assert_equal "01", e.value
    robot.pl_select_option("//div[@id='selects']/div[@class='classDT']", 10)
    assert_equal "dix", e.value
  end

  test "pl_click_on_radio" do
    span = robot.pl_driver.find_element(xpath: "//form//*[@id='radiosSpan']")
    radios = span.find_elements(xpath: ".//input[@type='radio']")
    checked = radios.find_all { |r| r["checked"] == "true" }
    assert_equal 1, checked.size
    assert_equal "", checked.first["value"]

    robot.pl_click_on_radio("//span[@id='radiosSpan']/label[2]/input")
    checked = radios.find_all { |r| r["checked"] == "true" }
    assert_equal 1, checked.size
    assert_equal "mandatory", checked.first["value"]

    robot.pl_click_on_radio("//span[@id='radiosSpan']", "optionnal")
    checked = radios.find_all { |r| r["checked"] == "true" }
    assert_equal 1, checked.size
    assert_equal "optionnal", checked.first["value"]


    robot.pl_click_on_radio("//span[@id='radiosSpan']/label[1]")
    checked = radios.find_all { |r| r["checked"] == "true" }
    assert_equal 1, checked.size
    assert_equal "", checked.first["value"]
  end

  test "pl_tick_checkbox" do
     c = robot.find("//form//input[@class='class2']").first
     assert_nil c["checked"]
     robot.pl_tick_checkbox("//form//input[@class='class2']")
     assert_not_nil c["checked"]
     
     robot.pl_tick_checkbox("//form//input[@class='class2']")
     assert_not_nil c["checked"]

     c.click
     assert_nil c["checked"]

     robot.pl_tick_checkbox("//form//label[3]")
     assert_not_nil c["checked"]
  end

  test "pl_untick_checkbox" do
     c = robot.find("//form//input[@class='class2']").first
     assert_not_nil c["checked"]
     robot.pl_untick_checkbox("//form//input[@class='class2']")
     assert_nil c["checked"]
     
     robot.pl_untick_checkbox("//form//input[@class='class2']")
     assert_nil c["checked"]

     c.click
     assert_not_nil c["checked"]

     robot.pl_untick_checkbox("//form//label[3]")
     assert_nil c["checked"]
  end

  test "get_price" do
    assert_equal 41.50, robot.get_price("41,50 €")
    assert_equal 289.90, robot.get_price("289€90")
    assert_equal 289.90, robot.get_price("289 € 90")
    assert_equal 6.99, robot.get_price("Livraison à partir de 6.99€")
    assert_equal 728.0, robot.get_price("EUR 728,00")
    assert_equal 20.0, robot.get_price("+ EUR 20,00 (livraison)")
    assert_equal 6.30, robot.get_price("+ 6,30 € (frais de port)")
    assert_equal 0.0, robot.get_price("LIVRAISON GRATUITE")
    assert_equal 0.0, robot.get_price("Expedition : FREE !")
    assert_raise ArgumentError do
      robot.get_price("Il n'y a pas de prix ici")
    end
  end

  test "z driver quit" do
    robot.driver.quit
  end

end
