require 'active_model'

class Template
  include ActiveModel::Model
  attr_accessor :path, :source
  delegate :name, :'name=', :notes, :'notes=',:host, :'host=',:script_path, :'script=',to: :manifest

  def persisted?
    false
  end

  def self.all
    Source.my.templates.concat(Source.system.templates).sort
  end

  def self.default
    Source.default
  end

  def initialize(path, source = Source.new("", Pathname.new("")))
    @path = Pathname.new(path)
    @source = source
  end

  def manifest
    @manifest ||= Manifest.load(path.join("manifest.yml"))
  end

  def writable?
    return @writable if defined?(@writable)

    if path && path.directory?
      @writable = path.writable?
    else
      @writable = false
    end

    @writable
  end

  def system?
    true
  end

  def default?
    self.path == Pathname.new(Template.default)
  end

  # Provide the http path to the file manager
  def file_manager_path
    # Use File.join because URI.join does not respect relative urls
    # TODO: Refactor FileManager into an initializer or helper class.
    #       This will be used elsewhere and often.
    File.join(FileManager[:fs], path.to_s)
  end

  def script_dir
    path.to_s
  end

  # Custom sort for templates.
  #   1. Default Template First
  #   2. My templates, alphabetically
  #   3. System templates, alphabetically
  def <=>(o)
    # Default template goes first (there should only be one)
    if self.default?
      return -1
    elsif o.default?
      return 1
    end

    # Sort the remaining templates My > System
    if self.source.my? && o.source.system?
      return -1
    elsif self.source.system? && o.source.my?
      return 1
    end

    # Sort templates by name
    self.name.upcase <=> o.name.upcase
  end
end
