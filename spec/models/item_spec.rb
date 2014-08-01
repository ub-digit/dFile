require "rails_helper"

RSpec.configure do |c|
  c.include ModelHelper
end

describe Item do
	before :each do
		@test_path = Rails.root.to_s + "/tmp/testdata/"
		initiate_test_environment(@test_path)
	end
	it "should have path after init" do
		item = Item.new(Path.new("TEST:123"))
		expect(item.path).to be_a Path
	end
	it "should copy a file successfully" do
		source_file = create_file(@test_path + "testfile.txt")
		source_item = Item.new(Path.new(source_file.path))

		dest_item = Item.new(Path.new(@test_path + "/copy/copy.txt"))

		source_item.copy_to(dest_item)

		expect(dest_item.path.exist?).to be true
		expect(dest_item.path.file?).to be true
		expect(dest_item.size == source_item.size).to be true
	end
	it "should copy a folder of files successfully" do
		source_dir = @test_path + "test_folder"
		create_folder_with_files(source_dir)
		source_item = Item.new(Path.new(source_dir))

		dest_item = Item.new(Path.new(@test_path + "copy/copyfolder"))

		source_item.copy_files_to(dest_item,'txt')

		expect(dest_item.path.files('txt').size == source_item.path.files('txt').size).to be true
	end
	it "should move a file successfully" do
		source_file = create_file(@test_path + "testfile.txt")
		source_item = Item.new(Path.new(source_file.path))

		dest_item = Item.new(Path.new(@test_path + "/copy/copy.txt"))
		source_size = source_item.size
		source_item.move_to(dest_item)

		expect(dest_item.path.exist?).to be true
		expect(dest_item.path.file?).to be true
		expect(source_item.path.exist?).to be false
		expect(dest_item.size == source_size).to be true
	end
	it "should move a folder of files successfully" do
		source_dir = @test_path + "test_folder"
		create_folder_with_files(source_dir)
		source_item = Item.new(Path.new(source_dir))

		dest_item = Item.new(Path.new(@test_path + "copy/copyfolder"))

		source_size = source_item.path.file_count('txt')
		source_item.move_files_to(dest_item,'txt')

		expect(dest_item.path.files('txt').size == source_size).to be true
		expect(source_item.path.file_count('txt')).to be 0
	end
	it "should copy and convert an image successfully" do
		source_file = @test_path + "testfile.tif"
		create_image(source_file)
		source_item = Item.new(Path.new(source_file))

		dest_item = Item.new(Path.new(@test_path + "/copy/copy.jpg"))

		source_item.copy_and_convert_to(dest_item, 50, 25)

		expect(dest_item.path.exist?).to be true
		expect(dest_item.path.file?).to be true
	end
	it "should copy and convert a folder of images successfully" do
		source_dir = @test_path + "test_folder"
		create_folder_with_images(source_dir)
		source_item = Item.new(Path.new(source_dir))

		dest_item = Item.new(Path.new(@test_path + "copy/copyfolder"))

		source_item.copy_and_convert_files_to(dest_item,'jpg', 'jpg', 50, 25)

		expect(dest_item.path.files('jpg').size == source_item.path.files('jpg').size).to be true
	end
end