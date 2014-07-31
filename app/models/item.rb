class Item
	attr_accessor :path

	def initialize(path)
		@path = path
	end

	# Returns all Items in a directory
	def self.all(dir)
		@path.children.each do |child|
			items << Item.new(child)
		end
	end

	# Returns checksum of file object
	def checksum
		@checksum ||= FileManager.checksum(@path)
#		if file?
#			return FileManager.checksum(@path)
#		end
end

	# Copies file to destination file
	def copy_to(dest_file)
		return false if !file_exist?
		
		return false if !dest_file.path.create_structure

		return false if !FileManager.copy(@path,dest_file.path)

		return true
	end

	# Copies all files of given type to destination directory
	def copy_files_to(dest_dir, type)
		return false if !dir?

		files = @path.files(type)
		files.each do |source_file|
			dest_file = Item.new(Path.new("#{dest_dir.path}/#{source_file.path.basename}"))
			return false if !source_file.copy_to(dest_file)
		end

		return true
	end

	def dir?
		@path.directory?
	end

	def file?
		@path.file?
	end

	def exist?
		@path.exist?
	end

	def file_exist?
		@path.exist? && @path.file?
	end

	def size
		@path.exist? ? @path.size : 0
	end

	def empty?
		@path.size < 1
	end

	def as_json(options={})
		{
			name: @path.basename.to_s,
			size: size
		}
	end

end