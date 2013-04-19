require 'test_helper'

class LogTest <  ActiveSupport::TestCase
   
  test "something interesting" do
    puts Log.count
    Log.create(:session => {uuid:"89989"})
    puts Log.first.session.inspect
    puts Log.first.inspect
    # puts Log.create.inspect
  end
  
end