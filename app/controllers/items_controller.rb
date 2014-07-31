class ItemsController < ActionController::Base

	# Calculate checksum of file
	def checksum 
		file = Item.new(Path.new(params[:file_path]))
		return file.checksum
	end	

	#Copies a file as given destination file
	def copy_file
		source_file = Item.new(Path.new(params[:source]+"."+params[:type]))
		dest_file = Item.new(Path.new(params[:dest]+"."+params[:type]))
		response = {}
		response[:source_file] = source_file
		response[:dest_file] = dest_file
		if source_file.copy_to(dest_file)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	# Copies files of a given type from a source directory to destination
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

	# Combines pdf files within a source directory and stores them as a single file
	def combine_pdf_files
		source_dir = Item.new(Path.new(params[:source]))
		dest_file = Item.new(Path.new(params[:dest]+".pdf"))

		response = {}
		if !source_dir.path.exist?
			response[:msg] = "Fail"
			render json: response
			return
		end

		dest_file.path.create_structure
		pdf_files = source_dir.path.files_as_array('pdf')

		response[:source_dir] = source_dir
		response[:dest_file] = dest_file
		response[:files_combined_count] = pdf_files.size

		if FileManager.combine_pdf_files(pdf_files,dest_file.path)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	#Moves files of a given type from a source directory to destination
	def move_files
		source_dir = Item.new(Path.new(params[:source]))
		dest_dir = Item.new(Path.new(params[:dest]))
		type  = params[:type]
		response = {}
		response[:source_dir] = source_dir
		response[:dest_dir] = dest_dir
		if source_dir.move_files_to(dest_dir, type)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	# Returns file count of specific file type in given directory
	def file_count
		source_dir = Item.new(Path.new(params[:source]))
		type = params[:type]

		response = {}
		response[:source_dir] = source_dir
		file_count = source_dir.path.file_count(type)
		
		if file_count
			response[:msg] = "Success"
			response[:file_count] = file_count
		else
			response[:msg] = "Fail"
		end
		render json: response
	end
end