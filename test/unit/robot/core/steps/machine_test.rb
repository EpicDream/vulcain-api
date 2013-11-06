require 'test_helper'
require 'robot/core/machine'
require 'robot/core/steps/registration'
require 'robot/core/steps/start'
require 'robot/core/context/context'

class MachineTest <  ActiveSupport::TestCase
   
    
  setup do
    @context = Robot::Context.new({'account' => {'new_account' => true}})
    @machine = Robot::State::Machine.new(@context)
  end
  
  test "step from start to registration" do
    Robot::Step::Registration.any_instance.stubs(:run).returns(false)
    Robot::Step::Start.any_instance.stubs(:run).returns(true)
    
    @machine.step
    
    assert_equal [:Start, :Registration], @machine.steps
  end
  
end