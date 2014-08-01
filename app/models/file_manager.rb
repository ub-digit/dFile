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
		checksum_value = nil
		file_path.open("rb") do |file|
			checksum_value = Digest::SHA512.hexdigest(file.read)
		end
		checksum_value
	end

	# Combines a list of files into a destination file
	def self.combine_pdf_files(files, dest_file)
		#`gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=#{dest_file.to_s} #{files.join(" ")}` #Use ghostScript to combine pdf-files
		args = ['gs', '-dBATCH', '-dNOPAUSE', '-q', '-sDEVICE=pdfwrite', "-sOutputFile=#{dest_file.to_s}"] + files
		execute(args)
	end

	# Copies file to destination path 
	def self.copy_and_convert(source_path, dest_path, quality = nil, size = nil)
		arguments = ""
		if quality then arguments += "-quality #{quality} " end
		if size then arguments += "-resize #{size}% " end
		args = ["convert", source_path.to_s] + arguments.split(/\s+/) + [dest_path.to_s]
		execute(args)
		return true
	end

	def self.execute(args)
		output = nil
		IO.popen(args) { |io_read|
			io_read.read
		}
	end
end