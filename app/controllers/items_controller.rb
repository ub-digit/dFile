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
		#response[:source_file] = source_file
		#response[:dest_file] = destination_file
		if source_file.copy_to(destination_file)
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

	# Sorts a list of files based on filename
	def sort_files(files)
		files.sort_by { |x| x.basename.to_s[/^(\d+)\./,1].to_i }.map
	end
end