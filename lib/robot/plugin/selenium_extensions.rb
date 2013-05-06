# encoding: utf-8

class Selenium::WebDriver::Element
  def parent
    self.find_element(xpath: "./..")
  end
  def tick
    self.click unless self["checked"]
    self
  end
  def id
    self["id"]
  end
  def classes
    self["class"].split(" ").compact
  end
  def has_class?(c)
    self.classes.include?(c)
  end
  def value
    self["value"]
  end
  def checked?
    !! self["checked"]
  end
end

class Selenium::WebDriver::Support::Select
  def select!(value)
    if value.kind_of?(Array)
      return value.find { |v| select(v) }
    end

    if value.kind_of?(Integer) && value != 0
      o = options.detect do |o|
        o.value.to_i == value || o.text.to_i == value
      end
    elsif value.kind_of?(Regexp)
      o = options.detect do |o|
        o.value =~ value || o.text =~ value
      end
    else
      o = options.detect do |o|
        o.value == value.to_s || o.text == value.to_s
      end
    end
    if o.nil?
      options.map { |op| [op.value.to_i, op.text.to_i] }
      raise Selenium::WebDriver::Error::NoSuchElementError, "cannot locate option with value: #{value.inspect}" 
    end
    select_options [o]
  end
  def select(value)
    return select!(value)
  rescue Selenium::WebDriver::Error::NoSuchElementError
    return nil
  end
end