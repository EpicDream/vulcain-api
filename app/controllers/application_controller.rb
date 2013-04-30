require 'dispatcher'

class ApplicationController < ActionController::API

  def assert_keys keys, expected
    expected.to_set.subset?(keys.to_set)
  end

end
