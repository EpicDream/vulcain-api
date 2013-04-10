# encoding: utf-8

if defined?(Driver)
  Object.send(:remove_const, :Driver)
end

if defined?(Strategy)
  Object.send(:remove_const, :Strategy)
end

if defined?(Amazon)
  Object.send(:remove_const, :Amazon)
end
