require "rails_helper"

RSpec.configure do |c|
	c.include ModelHelper
end

describe ItemsController do
	before :each do
		@test_path = Rails.root.to_s + "/tmp/testdata/"
		initiate_test_environment(@test_path)
	end
	describe "GET copy_file" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :copy_file, source: "12", dest: "13", type: "txt"
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Copies a file successfully" do
				create_file(@test_path + "testfile.txt")
				get :copy_file, source: @test_path + "testfile", dest: @test_path + "copied", type: "txt"
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET copy_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :copy_files, source: "12", dest: "13", type: "txt"
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Copies files successfully" do
				source_dir = @test_path + "test_folder"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "test_folder"))
				dest_item = Item.new(Path.new(@test_path + "copied"))
				get :copy_files, source: source_dir, dest: @test_path + "copied", type: "txt"
				expect(source_item.size == dest_item.size).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET move_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :move_files, source: "12", dest: "13", type: "txt"
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Moves files successfully" do
				source_dir = @test_path + "test_folder"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "test_folder"))
				source_size = source_item.size
				dest_item = Item.new(Path.new(@test_path + "copied"))
				get :move_files, source: source_dir, dest: @test_path + "copied", type: "txt"
				expect(source_size == dest_item.size).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET combine_pdf_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :combine_pdf_files, source: "12", dest: "13"
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Creates pdf successfully" do
				
				source_dir = @test_path + "pdf"
				create_pdf_folder(source_dir)
				dest_item = Item.new(Path.new(@test_path + "full.pdf"))
				
				get :combine_pdf_files, source: source_dir, dest: @test_path + "full"
				
				expect(dest_item.path.exist? && dest_item.path.file?).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET file_count" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :file_count, source: "12", type: "pdf"
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Creates pdf successfully" do
				
				source_dir = @test_path + "text_files"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "text_files"))
				
				get :file_count, source: source_dir, type: "txt"
				
				expect(json['file_count'] == source_item.path.file_count("txt")).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET list_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :list_files, source: "12", type: "pdf"
				expect(json.size).to be 0
			end 
		end
		context "with valid attributes" do 
			it "returns a list af files" do
				
				source_dir = @test_path + "text_files"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "text_files"))
				
				get :list_files, source: source_dir
				
				expect(json.size).to be 6
			end
		end
	end
	describe "GET get_image" do 
		context "with invalid attributes" do 
			it "returns a 404 error" do 
				response = get :get_image, source: "12", type: "tif"
				expect(response.status).to be 404
			end
		end
		context "with valid attributes" do 
			it "returns an image" do

				source_dir = @test_path + "test_image"
				create_image(source_dir + ".jpg")
				
				result = get :get_image, source: source_dir, type: "jpg"
				expect(result.body).to eq IO.binread(source_dir + ".jpg")
			end
		end
	end
end