require_relative '../../spec_helper'
require_relative "fixtures/classes"

ruby_version_is "3.0" do
  describe "A non blockign fiber with a scheduler" do
    it "calls `process_wait` on the scheduler when `Process::Status.wait` is called" do
      wait_count = 0
      Thread.new do
        Fiber.set_scheduler (Class.new (FiberSpecs::BlockUnblockScheduler) do
          define_method(:process_wait) do |pid, flags|
            wait_count = wait_count + 1
            Thread.new do
              Process::Status.wait(pid, flags)
            end.value
          end
        end).new

        pid = Process.spawn(ruby_cmd('exit'))
        Fiber.schedule { Process::Status.wait }
      end.join
      wait_count.should == 1
    end
  end
end
