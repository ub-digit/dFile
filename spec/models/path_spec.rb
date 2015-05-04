require "rails_helper"

RSpec.configure do |c|
  c.include ModelHelper
end

describe Path do
	before :each do
		@test_path = Rails.root.to_s + "/tmp/testdata/"
		initiate_test_environment(@test_path)
	end
	it "should have path after init" do
		path = Path.new("TEST:123")
		expect(path).to be_a Path
	end

	it "should raise error if path is outside root" do
		expect { Path.new("TEST:../../123") }.to raise_error(StandardError)
	end

	it "should work without prefix" do
		path = Path.new(@test_path)
		expect(path.to_s == @test_path).to be true
	end
	it "should return list of files" do
		create_folder_with_files(@test_path + "testfolder")
		path = Path.new(@test_path + "testfolder")
		expect(path.files('txt').size).to be 5
	end
end
