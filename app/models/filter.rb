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
  #   f.filter_block = Proc.new { |id, attr| attr[:Job_Owner] =~ /^#{user}@/ }
  # }
  self.list = []

  # Add a filter by user option.
  self.list << Filter.new.tap { |f|
    user = OodSupport::User.new.name
    f.title = "Your Jobs"
    f.cookie_id = "user"
    f.filter_block = Proc.new { |id, attr| attr[:Job_Owner] =~ /^#{user}@/ }
  }
  # Add a filter by group option.
  # TODO: Move this to an initializer. Not all centers may have linux groups.
  self.list << Filter.new.tap { |f|
    group = OodSupport::User.new.group.name
    f.title = "Your Group's Jobs (#{group})"
    f.cookie_id = "group"
    # N.B. Need to use :egroup here for now. My Oodsupport group name is 'appl' but job 'Account_Name' is 'PZS0002'
    f.filter_block = Proc.new { |id, attr| attr[:egroup] == group }
  }
  # Add a filter by all jobs option.
  # TODO: This should be a default option. App will crash if no filters are set.
  self.list << Filter.new.tap { |f|
    f.title = "All Jobs"
    f.cookie_id = "all"
  }

end
