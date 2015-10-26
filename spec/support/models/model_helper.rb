module ModelHelper
	
	# Creates folder for testing purposes
	def create_folder(path)
		FileUtils.mkdir_p(path)
	end

	# Deletes tes data folder
	def delete_folder
		FileUtils.rm_r(path)
	end

	def initiate_test_environment(test_path)
		Rails.configuration.dfile_paths["TEST"]	= test_path
		if Pathname.new(test_path).exist?
		  FileUtils.rm_r(test_path) # Delete exisiting test path
		end
		FileUtils.mkdir(test_path) # Create new test folder
	end

	def create_file(file_path, data = "A string to verify that this file is part of a test")
		file = File.open(file_path,'w')
		file.write(data)
		file.close
		return file
	end

	def create_folder_with_files(dir_path)
		FileUtils.mkdir(dir_path)
		5.times do |x|
			create_file(dir_path + "/test_file#{x}.txt")
		end
		create_file(dir_path + "/test_file_10.doc")
	end

	def create_folder_with_images(dir_path)
		FileUtils.mkdir_p(dir_path)
		5.times do |x|
			create_image(dir_path + "/test_file#{x}.jpg")
		end
		create_image(dir_path + "/test_file_10.tif")
	end

	def create_image(file_path)
		`convert -size 100x100 xc:white #{file_path}`
	end

	def create_pdf_folder(dir_path)
		create_folder(dir_path)
		10.times do |x|
			create_image(dir_path + "/test_pdf#{x}.pdf")
		end
	end

	def json
		@json ||= JSON.parse(response.body)
	end
end
