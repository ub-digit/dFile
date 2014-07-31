class Item
	attr_accessor :path

	def initialize(path)
		@path = path
	end

	#Returns all Items in a directory
	def self.all(dir)
		@path.children.each do |child|
			items << Item.new(child)
		end
	end

	# Returns checksum of file object
	def checksum
		if self.file?
			return FileManager.checksum(self)
		end
	end

	# Copies file to destination file
	def copy_to(dest_file)
		return false if !file_exist?
		
		return false if !dest_file.path.create_structure

		return false if !FileManager.copy(@path,dest_file.path)

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
		@path.size
	end

	def as_json(options={})
		{
			name: @path.basename.to_s,
			size: @path.size
		}
	end
end