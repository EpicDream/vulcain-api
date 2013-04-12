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