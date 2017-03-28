class Filter
  attr_accessor :title, :cookie_id, :filter_block

  class << self
    attr_accessor :list
  end

  # Apply the current filtering proc to an array of jobs.
  #
  # @return [Array] The filtered array.
  def apply(job_array)
    self.filter_block ? job_array.select(&filter_block) : job_array
  end

  # Provide the cookie_id to be used for the default filter.
  #
  # @return [String] The id of the default filter
  def self.default_id
    "user"
  end

  # Maintains a list of Filter objects.
  #
  # Add new filter objects via the format:
  # self.list << Filter.new.tap { |f|
  #   user = OodSupport::User.new.name
  #   f.title = "Your Jobs"
  #   f.cookie_id = "user"
  #   f.filter_block = Proc.new { |job| job.job_owner == user }
  # }
  self.list = []

  # Add a filter by user option.
  Filter.list << Filter.new.tap { |f|
    user = OodSupport::User.new.name
    f.title = "Your Jobs"
    f.cookie_id = "user"
    f.filter_block = Proc.new { |job| job.job_owner == user }
  }

  # Add a filter by all jobs option.
  Filter.list << Filter.new.tap { |f|
    f.title = "All Jobs"
    f.cookie_id = "all"
  }
end
