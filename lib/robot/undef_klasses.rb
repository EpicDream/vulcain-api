# encoding: utf-8

if defined?(Driver)
  Object.send(:remove_const, :Driver)
end

if defined?(Robot)
  Object.send(:remove_const, :Robot)
end

@vendors.each do |vendor|
  if defined?(Object.const_get(vendor))
    Object.send(:remove_const, vendor.to_sym)
  end rescue nil
end


