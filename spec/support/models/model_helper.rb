module ModelHelper
	
	# Creates folder for testing purposes
	def create_folder(path)
		FileUtils.mkdir(path)
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

	def create_file(file_path)
		file = File.open(file_path,'w')
		file.puts("A string to verify that this file is part of a test")
		file.close
		return file
	end
end