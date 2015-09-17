require "rails_helper"

RSpec.configure do |c|
  c.include ModelHelper
end

RSpec.describe QueueManager, type: :model do
	before :each do
		$redis.flushdb
	end

  describe "run" do
    
    context "when one CHECKSUM job is QUEUED" do
      it "should " do
      end
    end

    context "when ther are no queued jobs" do
      it "should not afffect any keys in redis" do
        QueueManager.new.run

        expect($redis.keys).to eq []
      end
    end
  end

  
end
