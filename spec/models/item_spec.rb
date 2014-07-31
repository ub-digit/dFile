require "rails_helper"

RSpec.configure do |c|
  c.include ModelHelper
end

describe Item do
	before :each do
		@test_path = Rails.root.to_s+"/tmp/testdata/"
		initiate_test_environment(@test_path)
	end
	it "should have path after init" do
		item = Item.new(Path.new("TEST:123"))
		expect(item.path).to be_a Path
	end
	it "should copy a file successfully" do
		source_file = create_file(@test_path+"testfil.txt")
		source_item = Item.new(Path.new(source_file.path))

		dest_item = Item.new(Path.new(@test_path+"/kopia/kopia.txt"))

		source_item.copy_to(dest_item)
		source_file

		expect(dest_item.path.exist?).to be true
		expect(dest_item.path.file?).to be true
		expect(dest_item.size == source_item.size).to be true
	end
end