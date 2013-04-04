require 'minitest/autorun'

def require_lib libname
  require File.join(File.dirname(__FILE__), "../lib/#{libname}")
end

require_lib 'core/driver'
require_lib 'core/strategy'

require 'mocha/setup'