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

  # Returns all Items in current directory
  def child_items
    items = []
    if dir?
      @path.sort_files(@path.children).each do |child|
        if child.directory?
          child = Path.new(child)
        end
        items << Item.new(child)
      end
      return items
    end
    nil
  end

	# Returns checksum of file object
	def checksum
		@checksum ||= FileManager.checksum(@path)
    #		if file?
    #			return FileManager.checksum(@path)
    #		end
  end

  def create(content)
    return false if file_exist?

    return false if !path.create_structure

    return false if !FileManager.create(@path,content)

    return true
  end

	# Copies file to destination file
	def copy_to(dest_file)
		return false if !file_exist?
		
		return false if !dest_file.path.create_structure

		return false if !FileManager.copy(@path,dest_file.path)

		return true
	end

	# Moves file to destination file
	def move_to(dest_file)
		return false if !exist?
		
		return false if !dest_file.path.create_structure

		return false if !FileManager.move(@path,dest_file.path)

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

	# Copies all files of given type to destination directory
	def move_files_to(dest_dir, type)
		return false if !dir?

		files = @path.files(type)
		files.each do |source_file|
			dest_file = Item.new(Path.new("#{dest_dir.path}/#{source_file.path.basename}"))
			return false if !source_file.move_to(dest_file)
		end

		return true
	end

	# Copies file to destination file
	def copy_and_convert_to(dest_file, quality = nil, size = nil)
		return false if !file_exist?

		return false if !dest_file.path.create_structure

		return false if !FileManager.copy_and_convert(@path,dest_file.path, quality, size)
		
		return true
	end

	# Copies and converts all files of given type to destination directory
	def copy_and_convert_files_to(dest_dir, source_type, dest_type = nil, quality = nil, size = nil)
		return false if !dir?
		dest_file_type = dest_type || source_type
		files = @path.files(source_type)
		files.each do |source_file|
			dest_file = Item.new(Path.new("#{dest_dir.path}/#{source_file.filename}.#{dest_file_type}"))
			return false if !source_file.copy_and_convert_to(dest_file, quality, size)
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

	def filename
		@path.basename('.*')
	end

	def as_json(options={})
    if dir?
      {
       name: @path.basename.to_s,
       children: child_items
     }
   else
    {
      name: @path.basename.to_s,
      size: size
    }
  end
end

end