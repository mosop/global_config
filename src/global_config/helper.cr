module GlobalConfig
  def self.env?(*names)
    names.each do |name|
      if v = ENV[name]?
        return v
      end
    end
    nil
  end
end
