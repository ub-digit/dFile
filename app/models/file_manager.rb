class FileManager
  
  # Copies source path to destination path 
  def self.copy(source_path, dest_path)
    FileUtils.cp(source_path, dest_path)
    return true
  end

  # Removes source directory
  def self.delete_directory(path)
    FileUtils.rm_rf(path)
  end

  def self.move(source_path, dest_path)
    FileUtils.mv(source_path.to_s, dest_path.to_s)
  end

  def self.create(dest_path, content, permission=nil)
    file = File.open(dest_path, "w:utf-8") do |file|
      file.write(content)
    end
    if permission.present?
      FileUtils.chmod(permission.to_i(8), dest_path)
    end

    return file
  end

  # creates catalog structure for given path
  def self.create_structure(path, permission=nil)
    FileUtils.mkdir_p(path)
    if permission.present?
      FileUtils.chmod(permission.to_i(8), path)
    end
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

  # Combines a list of files into a destination file using ghostscript
  def self.combine_pdf_files(files, dest_file)
    args = ['gs', '-dBATCH', '-dNOPAUSE', '-q', '-sDEVICE=pdfwrite', "-sOutputFile=#{dest_file.to_s}"] + files
    execute(args)
  end

  # Copies file to destination path 
  def self.copy_and_convert(source_path:, dest_path:, quality: nil, size: nil, arguments: "")
    if quality then arguments += "-quality #{quality} " end
    if size then arguments += "-resize #{size} " end
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

  def self.rename(from_file:, to_file:)
    File.rename(from_file, to_file)
    true
  end
end
