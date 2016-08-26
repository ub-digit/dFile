require 'free_disk_space'

class Path < Pathname

  attr_accessor :input_root,:input_path

	# WORK:/114/master/0001.tif
	# root: WORK
	# path: /114/master/0001.tif
	# rootpath: config["WORK"] => /mnt/laban
	# super(rootpath+path)
	def initialize(input_path)
		return super('') if input_path.nil?
		return super(input_path) if !input_path.index(":")
		root,path = input_path.split(":")
    @input_root = root
    @input_path = path
		rootpath = lookup_config_path(root)
    root_pathname = Pathname.new(rootpath)
		output_pathname = super(rootpath+path)
    if output_pathname.relative_path_from(root_pathname).to_s[/^\.\./]
      raise StandardError, "Requested path outside root path"
    end
    if output_pathname.relative_path_from(root_pathname).to_s == "."
      raise StandardError, "Requested path is root path. Must be subpath of root."
    end
    output_pathname
	end

	# Returns path from config based on key
	def lookup_config_path(key)
		path = Rails.configuration.dfile_paths[key]
    if !path
      raise StandardError, "Requewted rootpath #{key} is not configured"
    end
    return path
	end

	# Returns all children of given filetype
	def files(file_type: nil, show_catalogues: true, nested_files: false)
		return [] if !directory?
		items = []
		sort_files(children).each do |child|
      if child.directory? && nested_files
        items += child.files(file_type: file_type, show_catalogues: show_catalogues)
      end
			next if !child.file? && !show_catalogues
			next if file_type && child.extname != ".#{file_type}" && !child.directory?
			items << Item.new(Path.new(child.to_s))
		end
		items
	end

	# Returns all children of given filetype as an array
	def files_as_array(file_type = nil)
		items = files(file_type: file_type, show_catalogues: false)
		file_list = []
		items.each do |item|
			file_list << item.path.to_s
		end
		return file_list
	end

	def file_count(file_type: nil, show_catalogues: true)
		return nil if !exist? || !directory?
		return files(file_type: file_type, show_catalogues: show_catalogues).size
	end

  def total_size
    size = 0
    self.all_files.each do |file|
      begin
        size += file.size
      rescue StandardError => e
        Rails.logger.info "Couldn't read size from file #{file}"
      end
    end
    return size / 1024 / 1024 # Returns size in MB
  end

  def all_files
    return @all_files if @all_files.present?
    @all_files = []
    sort_files(children).each do |child|
      if child.directory?
        @all_files += Path.new(child.to_s).all_files
      else
        @all_files << Item.new(Path.new(child.to_s))
      end
    end
    return @all_files
  end

  # creates catalog structure for the path
  def create_structure(permission=nil)
    FileManager.create_structure(self.dirname.to_s, permission)
  end

  # Sorts a list of files based on filename
  def sort_files(files)
    files.sort_by do |x|
      bname = x.basename.to_s
      numeric_subpart = 0
      numeric_file_part = bname[/^(\d+)/,1]
      if numeric_file_part.blank?
        numeric_file_part = 2**64-1
        numeric_subpart = bname.gsub(/[^\d]/,'')
        if numeric_subpart.blank?
          numeric_subpart = 2**64-1
        end
        numeric_subpart = numeric_subpart.to_i
      end
      numeric_file_part = numeric_file_part.to_i
#      tmp = x.basename.to_s[/^(\d+)\./,1].to_i 
      sort_order = [numeric_file_part, numeric_subpart]
      sort_order
    end.map
  end
end
