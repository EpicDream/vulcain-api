# encoding: utf-8

class Object
  def to_openstruct
    case self
    when Hash
      object = self.clone
      object.each do |key, value|
        object[key] = value.to_openstruct
      end
      OpenStruct.new(object)
    when Array
      object = self.clone
      object.map! { |element| element.to_openstruct }
    else
      self
    end
  end
end

module Enumerable
  # Allow to pass method and args without block.
  # Ex : [1,2,3,4].map_send(:+,1) => [2,3,4,5]
  def map_send(*args)
    map { |x| x.send(*args) }
  end

  # Delete one obj and return it, or nil if nothing found.
  def delete_one(obj=nil, &block)
    if obj
      return self.slice!(self.index(obj))
    elsif block
      self.each_with_index do |e,i|
        return self.slice!(i) if yield e
      end
    end
    nil
  end
  # Delete one obj and return the Enumerable
  def delete_one!(obj=nil, &block)
    if obj
      self.slice!(self.index(obj))
    elsif block
      self.each_with_index do |e,i|
        if yield e
          self.slice!(i)
          break
        end
      end
    end
    self
  end
  # Replace in place by arg if block return true.
  # [1,2,3,4,5,6].replace_by_if(0) { |n| n.even? } => [1,0,3,0,5,0]
  def replace_by_if(arg, &block)
    raise ArgumentError unless block
    self.each_with_index do |e,i|
      self[i] = arg if yield e
    end
  end
end

class String
  UNACCENT_HASH = {
    'A'   => 'ÀÁÂÃÄÅĀĂǍẠẢẤẦẨẪẬẮẰẲẴẶǺĄ',
    'a'   => 'àáâãäåāăǎạảấầẩẫậắằẳẵặǻą',
    'C'   => 'ÇĆĈĊČ',
    'c'   => 'çćĉċč',
    'D'   => 'ÐĎĐ',
    'd'   => 'ďđ',
    'E'   => 'ÈÉÊËĒĔĖĘĚẸẺẼẾỀỂỄỆ',
    'e'   => 'èéêëēĕėęěẹẻẽếềểễệ',
    'G'   => 'ĜĞĠĢ',
    'g'   => 'ĝğġģ',
    'H'   => 'ĤĦ',
    'h'   => 'ĥħ',
    'I'   => 'ÌÍÎÏĨĪĬĮİǏỈỊ',
    'i'   => 'ìíîï',
    'J'   => 'Ĵ',
    'j'   => 'ĵ',
    'K'   => 'Ķ',
    'k'   => 'ķ',
    'L'   => 'ĹĻĽĿŁ',
    'l'   => 'ĺļľŀł',
    'N'   => 'ÑŃŅŇ',
    'n'   => 'ñńņňŉ',
    'O'   => 'ÒÓÔÕÖØŌŎŐƠǑǾỌỎỐỒỔỖỘỚỜỞỠỢ',
    'o'   => 'òóôõöøōŏőơǒǿọỏốồổỗộớờởỡợð',
    'R'   => 'ŔŖŘ',
    'r'   => 'ŕŗř',
    'S'   => 'ŚŜŞŠ',
    's'   => 'śŝşš',
    'T'   => 'ŢŤŦ',
    't'   => 'ţťŧ',
    'U'   => 'ÙÚÛÜŨŪŬŮŰŲƯǓǕǗǙǛỤỦỨỪỬỮỰ',
    'u'   => 'ùúûüũūŭůűųưǔǖǘǚǜụủứừửữự',
    'W'   => 'ŴẀẂẄ',
    'w'   => 'ŵẁẃẅ',
    'Y'   => 'ÝŶŸỲỸỶỴ',
    'y'   => 'ýÿŷỹỵỷỳ',
    'Z'   => 'ŹŻŽ',
    'z'   => 'źżž',
    # Ligatures
    'AE'    => 'Æ',
    'ae'    => 'æ',
    'OE'    => 'Œ',
    'oe'    => 'œ'
  }

  def unaccent
    _str = self.clone
    UNACCENT_HASH.each do |k, v|
      _str.gsub!(/[#{v}]/, k)
    end
    _str
  end
end