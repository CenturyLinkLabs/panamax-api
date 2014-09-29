module FileReader
  refine File do
    def File.read_if_exists(file)
      File.read(file) if File.exists?(file.to_s)
    end
  end
end
