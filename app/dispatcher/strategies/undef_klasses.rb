if defined?(Driver)
  Object.send(:remove_const, Driver)
end

if defined?(Strategy)
  Object.send(:remove_const, Strategy)
end

if defined?(RueDuCommerce)
  Object.send(:remove_const, RueDuCommerce)
end