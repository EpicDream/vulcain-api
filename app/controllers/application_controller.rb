class ApplicationController < ActionController::API
  
  def assert_keys keys, expected
    keys.to_set == expected.to_set
  end

end
