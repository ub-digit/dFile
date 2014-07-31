class ItemsController < ActionController::Base

	# Calculate checksum of file
	def checksum 
		file = Item.new(Path.new(params[:file_path]))
		return file.checksum
	end	

	#Copies a file as given destination file
	def copy_file
		source_file = Item.new(Path.new(params[:source]+"."+params[:type]))
		destination_file = Item.new(Path.new(params[:dest]+"."+params[:type]))
		response = {}
		response[:source_file] = source_file
		response[:dest_file] = destination_file
		if source_file.copy_to(destination_file)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	#Copies files of a given type from a source directory to destination
	def copy_files
		source_dir = Item.new(Path.new(params[:source]))
		dest_dir = Item.new(Path.new(params[:dest]))
		type  = params[:type]
		response = {}
		response[:source_dir] = source_dir
		response[:dest_dir] = dest_dir
		if source_dir.copy_files_to(dest_dir, type)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	# Returns a list of all files in directory
	def list_files
		source_dir = Path.new(params[:source])
		render json: source_dir.files
	end
end