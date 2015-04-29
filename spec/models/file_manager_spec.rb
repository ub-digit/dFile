require "rails_helper"

RSpec.configure do |c|
	c.include ModelHelper
end

describe FileManager do
	before :each do
		@test_path = Rails.root.to_s + "/tmp/testdata/"
		initiate_test_environment(@test_path)
	end
	it "should copy a file successfully" do
		source_file = create_file(@test_path + "testfile.txt")
		source_path = Path.new(source_file.path)

		dest_path = Path.new(@test_path + "copy.txt")

		FileManager.copy(source_path,dest_path)

		expect(dest_path.exist?).to be true
		expect(dest_path.file?).to be true
		expect(dest_path.size == source_path.size).to be true
	end
	it "should move a file successfully" do
		source_file = create_file(@test_path + "testfile.txt")
		source_path = Path.new(source_file.path)

		dest_path = Path.new(@test_path + "copy.txt")
		source_size = source_path.size

		FileManager.move(source_path,dest_path)

		expect(dest_path.exist?).to be true
		expect(dest_path.file?).to be true
		expect(dest_path.size == source_size).to be true
	end
	it "should copy and convert an image successfully" do
		source_file = @test_path + "testfile.tif"
		create_image(source_file)
		source_path = Path.new(source_file)

		dest_path = Path.new(@test_path + "copy.jpg")

		FileManager.copy_and_convert(source_path, dest_path, 50, 25)

		expect(dest_path.exist?).to be true
		expect(dest_path.file?).to be true
	end
	it "should return a checksum" do
		source_file = @test_path + "testfile"
		create_file(source_file, 'teststring')
		source_path = Path.new(source_file)

		checksum = FileManager.checksum(source_path)
		checksum_test = Digest::SHA512.hexdigest('teststring')
		checksum_test2 = Digest::SHA512.hexdigest('teststring_two')

		expect(checksum == checksum_test).to be true
		expect(checksum == checksum_test2).to be false
	end
	it "should combine pdf files successfully" do
		source_dir = @test_path + "pdf"
		create_pdf_folder(source_dir)
		dest_path = Path.new(@test_path + "full.pdf")
		pdf_files = []
		10.times do |x|
			pdf_files << source_dir + "/test_pdf#{x}.pdf"
		end
		FileManager.combine_pdf_files(pdf_files,dest_path)

		expect(dest_path.exist? && dest_path.file?).to be true
	end

  it "should create a file successfully" do
    dest_file = Path.new(@test_path + "createdfile.txt")
    content = "random content"

    FileManager.create(dest_file, content)

    expect(dest_file.exist?).to be_truthy
    expect(dest_file.file?).to be_truthy
    expect(dest_file.size > 0).to be_truthy
    expect(File.new(dest_file).read).to eq "random content"
  end
end