require_relative '../../spec_helper'
require_relative "fixtures/classes"

ruby_version_is "3.0" do
  describe "A fiber scheduler" do
    it "raises a ThreadError if a dead fiber is resumed by the scheduler" do
      mutex = Mutex.new
      scheduler = Class.new(FiberSpecs::BlockUnblockScheduler) do
        def resume_execution(fiber)
          fiber.resume
          fiber.resume
        end
      end.new
      -> {Thread.new do
            Fiber.set_scheduler scheduler

            mutex.lock
            Fiber.schedule do
              begin
                mutex.lock
                mutex.unlock
              end
            end
            mutex.unlock
          end.join }.should raise_error(FiberError)
    end

    it "has unblock called even if for all cases even if one raised an exception" do
      mutex = Mutex.new
      scheduler = Class.new(FiberSpecs::BlockUnblockScheduler) do
        def unblock(blocker, fiber)
          super.unblock(blocker, fiber)
          raise RuntimeError, "Evil" unless Fiber.current == fiber
        end
      end.new
      Thread.new do
        Fiber.set_scheduler scheduler

        mutex.lock
        Fiber.schedule do
          begin
            mutex.lock
            mutex.unlock
          end
        end
        Fiber.schedule do
          begin
            mutex.lock
            mutex.unlock
          end
        end
        mutex.unlock
      end.join(5)
      scheduler.block_calls.should == 2
      scheduler.unblock_calls.should >= 2
    end
  end
end
