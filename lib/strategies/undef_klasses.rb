# encoding: utf-8

if defined?(Driver)
  Object.send(:remove_const, :Driver)
end

if defined?(Strategy)
  Object.send(:remove_const, :Strategy)
end

@strategies_vendors.each do |vendor|
  if defined?(Object.const_get(vendor))
    Object.send(:remove_const, vendor.to_sym)
  end rescue nil
end


