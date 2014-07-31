class FileManager
	# Copies file to destination path 
	def self.copy(source_path, dest_path)
		FileUtils.cp(source_path, dest_path)
		return true
	end

	def self.move(source_path, dest_path)
		FileUtils.mv(source_path, dest_path)
	end

	# creates catalog structure for given path
	def self.create_structure(path)
		FileUtils.mkdir_p(path)
		return true
	end

	# Returns checksum for a Pathname
	def self.checksum(file_path)
		return false if !file_path.file?
		file_path.open("rb") do |file|
			checksum = Digest::SHA512.hexdigest(file.read)
		end
		return checksum
	end

	# Combines a list of files into a destination file
	def self.combine_pdf_files(files, dest_file)
		`gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=#{dest_file.to_s} #{files.join(" ")}` #Use ghostScript to combine pdf-files
	end
end