class Path < Pathname

	# WORK:/114/master/0001.tif
	# root: WORK
	# path: /114/master/0001.tif
	# rootpath: config["WORK"] => /mnt/laban
	# super(rootpath+path)
	def initialize(input_path)
		return super('') if input_path.nil?
		return super(input_path) if !input_path.index(":")
		root,path = input_path.split(":")
		rootpath = lookup_config_path(root)
		super(rootpath+path)
	end

	# Returns path from config based on key
	def lookup_config_path(key)
		Rails.configuration.dfile_paths[key]
	end

	# Returns all children of given filetype
	def files(file_type = nil)
		items = []
		sort_files(children).each do |child|
			next if !child.file?
			next if file_type && child.extname != ".#{file_type}"
			items << Item.new(child)
		end
		items
	end

	# Returns all children of given filetype as an array
	def files_as_array(file_type = nil)
		items = files(file_type)
		file_list = []
		items.each do |item|
			file_list << item.path.to_s
		end
		return file_list
	end

	# creates catalog structure for the path
	def create_structure
		FileManager.create_structure(self.dirname.to_s)
	end

	# Sorts a list of files based on filename
	def sort_files(files)
		files.sort_by { |x| x.basename.to_s[/^(\d+)\./,1].to_i }.map
	end
end