require "rails_helper"

RSpec.configure do |c|
	c.include ModelHelper
end

describe ItemsController do
	before :each do
		@test_path = Rails.root.to_s + "/tmp/testdata/"
		initiate_test_environment(@test_path)
	end
	describe "POST copy_file" do 
		context "with valid attributes" do 
			it "returns a json message" do 
				post :copy_file, source: "12", dest: "13", type: "txt"
				expect(json['msg'] == "Fail").to be true
			end 
			it "Copies a file successfully" do
				create_file(@test_path + "testfile.txt")
				post :copy_file, source: @test_path + "testfile", dest: @test_path + "copied", type: "txt"
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "POST copy_files" do 
		context "with valid attributes" do 
			it "returns a json message" do 
				post :copy_file, source: "12", dest: "13", type: "txt"
				expect(json['msg'] == "Fail").to be true
			end 
			it "Copies files successfully" do
				source_dir = @test_path + "test_folder"
				create_folder_with_files(source_dir)
				post :copy_files, source: source_dir, dest: @test_path + "copied", type: "txt"
				expect(json['msg'] == "Success").to be true
			end
		end
	end
end