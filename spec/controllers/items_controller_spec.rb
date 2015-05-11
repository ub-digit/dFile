require "rails_helper"

RSpec.configure do |c|
	c.include ModelHelper
end

describe ItemsController do
	before :each do
    @api_key = Rails.application.config.api_key
		@test_path = Rails.root.to_s + "/tmp/testdata/"
    Rails.application.config.dfile_paths["TRASH"] = Rails.root.to_s + "/tmp/testdata/trash/"
    Rails.application.config.dfile_paths["PACKAGING"] = Rails.root.to_s + "/tmp/testdata/packaging/"
		initiate_test_environment(@test_path)
	end
	describe "GET copy_file" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :copy_file, source_file: "12.txt", dest_file: "13.txt", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Copies a file successfully" do
				create_file(@test_path + "testfile.txt")
				get :copy_file, source_file: @test_path + "testfile.txt", dest_file: @test_path + "copied.txt", api_key: @api_key
				expect(json['msg'] == "Success").to be true
        expect(response.status).to eq 200
			end
		end
	end
  describe "POST create_file" do
    context "With valid attributes" do
      it "should return success" do
        post :create_file, dest_file: @test_path + 'createdFile.txt', content: "My content", api_key: @api_key
        expect(json['msg'] == "Success").to be true
        expect(response.status).to eq 200
      end
    end
    context "With invalid attributes" do
      it "should return fail" do
        create_file(@test_path + "createdFile.txt")
        post :create_file, dest_file: @test_path + 'createdFile.txt', content: "My content", api_key: @api_key
        expect(json['msg'] == "Fail").to be true
        expect(response.status).to eq 422
      end
    end
  end
	describe "GET copy_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :copy_files, source: "12", dest: "13", type: "txt", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Copies files successfully" do
				source_dir = @test_path + "test_folder"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "test_folder"))
				dest_item = Item.new(Path.new(@test_path + "copied"))
				get :copy_files, source: source_dir, dest: @test_path + "copied", type: "txt", api_key: @api_key
				expect(source_item.size == dest_item.size).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET move_file" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :move_file, source: "12", dest: "13", type: "txt", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Moves a file successfully" do
				create_file(@test_path + "testfile.txt")
				get :move_file, source_file: @test_path + "testfile.txt", dest_file: @test_path + "moved.txt", api_key: @api_key
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET move_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :move_files, source: "12", dest: "13", type: "txt", api_key: @api_key
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
				get :move_files, source: source_dir, dest: @test_path + "copied", type: "txt", api_key: @api_key
				expect(source_size == dest_item.size).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET combine_pdf_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :combine_pdf_files, source: "12", dest: "13", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Creates pdf successfully" do
				
				source_dir = @test_path + "pdf"
				create_pdf_folder(source_dir)
				dest_item = Item.new(Path.new(@test_path + "full.pdf"))
				
				get :combine_pdf_files, source: source_dir, dest: @test_path + "full", api_key: @api_key
				
				expect(dest_item.path.exist? && dest_item.path.file?).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET file_count" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :file_count, source: "12", type: "pdf", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Creates pdf successfully" do
				
				source_dir = @test_path + "text_files"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "text_files"))
				
				get :file_count, source: source_dir, type: "txt", api_key: @api_key
				
				expect(json['file_count'] == source_item.path.file_count("txt")).to be true
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET list_files" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :list_files, source_dir: "12", type: "pdf", api_key: @api_key
				expect(json.size).to be 0
			end 
		end
		context "with valid attributes" do 
			it "returns a list af files" do
				
				source_dir = @test_path + "text_files"
				create_folder_with_files(source_dir)
				source_item = Item.new(Path.new(@test_path + "text_files"))
				
				get :list_files, source_dir: source_dir, api_key: @api_key
				
				expect(json.size).to be 6
			end
		end

    context "with a given file type" do 
      it "returns a list af files" do
        
        source_dir = @test_path + "text_files"
        create_folder_with_files(source_dir)
        source_item = Item.new(Path.new(@test_path + "text_files"))
        
        get :list_files, source_dir: source_dir, ext: 'txt', api_key: @api_key
        
        expect(json.size).to be 5
      end
    end

    context "with catalogues allowed" do
      it "returns a list of the entire folder structure" do
        source_dir = @test_path + "text_files"
        create_folder_with_files(source_dir)
        create_folder_with_files(source_dir + '/nested_files')
        source_item = Item.new(Path.new(@test_path + "text_files"))

        get :list_files, source_dir: source_dir, show_catalogues: true, api_key: @api_key

        expect(json.size).to be 7
        expect(json.find{|x| x["name"] == 'nested_files'}["children"].size).to be 6
      end
    end
	end
	describe "GET get_image" do 
		context "with invalid attributes" do 
			it "returns a 404 error" do 
				response = get :get_image, source: "12", type: "tif", api_key: @api_key
				expect(response.status).to be 404
			end
		end
		context "with valid attributes" do 
			it "returns an image" do

				source_dir = @test_path + "test_image"
				create_image(source_dir + ".jpg")
				
				result = get :get_image, source: source_dir, type: "jpg", api_key: @api_key
				expect(result.body).to eq IO.binread(source_dir + ".jpg")
			end
		end
	end

	describe "GET copy_and_convert_images" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :copy_and_convert_images, source: "12", dest: "13", source_type: "txt", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Copies files successfully" do
				source_dir = @test_path + "test_folder"
				create_folder_with_images(source_dir)
				source_item = Item.new(Path.new(@test_path + "test_folder"))
				dest_item = Item.new(Path.new(@test_path + "copied"))
				get :copy_and_convert_images, source: source_dir, dest: @test_path + "copied", source_type: "jpg", api_key: @api_key
				expect(json['msg'] == "Success").to be true
			end
		end
	end
	describe "GET copy_and_convert_image" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :copy_and_convert_image, source: "12", dest: "13", source_type: "tif", dest_type: "jpg", api_key: @api_key
				expect(json['msg'] == "Fail").to be true
			end 
		end
		context "with valid attributes" do 
			it "Copies files successfully" do
				create_image(@test_path + "testfile.tif")
				get :copy_and_convert_image, source: @test_path + "testfile", source_type: 'tif', dest: @test_path + "copied", dest_type: 'tif', quality: 50, size: 25, api_key: @api_key
				expect(json['msg'] == "Success").to be true
			end
		end
		context "with valid attributes without parameters" do 
			it "Copies files successfully" do
				create_image(@test_path + "testfile.tif")
				get :copy_and_convert_image, source: @test_path + "testfile", source_type: 'tif', dest: @test_path + "copied", api_key: @api_key
				expect(json['msg'] == "Success").to be true
			end
		end
	end

  describe "GET move_to_trash" do
    context "with valid folder that doesn't already exist in trash" do
      it "should move folder to trash folder" do
        source_dir = @test_path + "packaging/test_folder"
        create_folder_with_images(source_dir)
        get :move_to_trash, source_dir: "PACKAGING:test_folder", api_key: @api_key
        expect(response.status).to eq 200
      end
    end

    context "with an invalid folder" do
      it "should not return error message" do
        source_dir = @test_path + "packaging/test_folder"

        get :move_to_trash, source_dir: "PACKAGING:test_folder", api_key: @api_key
        expect(response.status).to eq 200
      end
    end

    context "with valid folder that already exist in trash" do
      it "should move folder to trash folder" do
        source_dir = @test_path + "packaging/test_folder"
        create_folder_with_images(source_dir)
        create_folder_with_images(@test_path + "/trash/test_folder")
        create_folder_with_images(@test_path + "/trash/test_folder_1")
        get :move_to_trash, source_dir: "PACKAGING:test_folder", api_key: @api_key
        expect(response.status).to eq 200
        expect(Item.new(Path.new(@test_path + "/trash/test_folder_1")).exist?).to be_truthy
        expect(Item.new(Path.new(@test_path + "/trash/test_folder_2")).exist?).to be_truthy
        expect(Item.new(Path.new(@test_path + "packaging/test_folder")).exist?).to be_falsey
      end
    end
  end
end