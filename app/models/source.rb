class Source
  attr_accessor :path, :name

  # Constructor
  # @param [String] name the human readable name of the source
  # @param [String] path the path to the source
  def initialize(name, path)
    @name = name
    @path = path
  end

  # @return [Source] A source that has been initialized to the system path.
  def self.system
    Source.new("System Templates", Rails.root.join('templates').to_s)
  end

  # @return [Source] A source that has been initialized to the user template path.
  def self.my
    Source.new("My Templates", OodAppkit.dataroot.join("templates").to_s)
  end

  # @return [Source] A source that has been initialized to the default path.
  def self.default
    Source.new("Default Template", Rails.root.join('templates').join("default").to_s)
  end

  # @return [Template] The default template.
  def self.default_template
    Template.new(Source.default.path, Source.default)
  end

  # @return [Array<Template>] The templates available on the path.
  def templates
    return [] unless Pathname.new(path).directory?

    folders = Dir.entries(path).sort
    # Remove "." and ".."
    folders.shift(2)

    # create a template for each folder
    folders.map {|f| Template.new(Pathname.new(path).join(f), self) }
  end
end
