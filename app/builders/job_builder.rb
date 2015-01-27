module JobBuilder

  def self.create(options)
    JobBuilder::FromTemplate.create_job(options)
  end

end
