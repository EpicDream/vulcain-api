require 'test_helper'

class LogTest <  ActiveSupport::TestCase
   
  test "play with mongo db" do
    Log.create(:step => 'login', :session => {uuid:"89989", callback_url:"http://shopelia.fr/callback"})
    log = Log.all(:conditions => {:step => 'login'}).first
    
    assert_equal 'login', log.step
    assert_equal '89989', log.session['uuid']
    assert_equal Date.today, log.created_at.to_date
  end
  
end