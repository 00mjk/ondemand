require 'yaml'

class Manifest

  class InvalidContentError < StandardError
    def initialize
      super %q(Manifest is not formatted correctly! 
Manifest should be in YAML format with markdown for description
---
name: Container Fill Sim
description: |
  This is a description.
  With **markdown**.

  And a

  * bullet
    * sub1
    * sub2
  * list

  Support:

  * [Company Website](https://www.osc.edu)

category: OSC
      )
    end
  end

  def self.load(yaml_path)
    if File.exist? yaml_path
      Manifest.new(YAML.load_file yaml_path)
    else
      MissingManifest.new({})
    end
  rescue Exception => e
    # FIXME: if we rescue from exceptions, we should store the exception
    # information in the manifest
    # and be explicit about what we are handling
    # probably a YAML formatting error?
    InvalidManifest.new(e)
  end

  def self.load_from_string(yaml)
    Manifest.new(YAML.load(yaml))
  rescue Exception => e
    InvalidManifest.new(e)
  end

  # @param [Hash] opts A hash of the options in the manifest
  # @option opts [String] :name The name of the application
  # @option opts [String] :description The description of the application
  # @option opts [String] :category The category of the application
  # @option opts [String] :subcategory The subcategory of the application
  # @option opts [String] :icon The icon used on the dashboard, optionally a Font Awesome tag
  # @option opts [String] :role Dashboard categorization
  # @option opts [String] :url An optional redirect URL
  def initialize(opts)
    raise InvalidContentError.new unless(opts && opts.is_a?(Hash))

    @manifest_options = opts.with_indifferent_access
  end

  # The name of the application
  #
  # @return [String] name as string
  def name
    @manifest_options[:name] || ""
  end

  # The description of the application
  #
  # @return [String] name as string
  def description
    @manifest_options[:description] || ""
  end

  # The icon used on the dashboard, optionally a Font Awesome tag
  #
  # @return [String, nil]
  def icon
    @manifest_options[:icon]
  end

  # Return the optional redirect URL string
  #
  # @return [String, nil]
  def url
    @manifest_options[:url]
  end

  # Return the app category
  #
  # @return [String, nil]
  def category
    @manifest_options[:category]
  end

  # Return the app subcategory
  #
  # @return [String, nil]
  def subcategory
    @manifest_options[:subcategory]
  end

  # Return the app role
  #
  # @return [String, nil]
  def role
    @manifest_options[:role]
  end

  # Manifest objects are valid
  #
  # @return [true] Always return true
  def valid?
    true
  end

  # Manifest objects exist
  #
  # @return [true] Always return true
  def exist?
    true
  end

  # Save the current manifest to a path.
  #
  # @param [String, Pathname] path The full path of the file to be saved as string or Pathname object
  #
  # @return [true, false] true if the file is saved successfully
  def save(path)

    File.open(path.to_s, 'w') do |f|
      f.write(self.to_yaml)
    end

    true
  rescue
    # TODO Add a custom exception here to track why it erred. IO? Permissions? etc.
    false
  end

  # Merge the contents of a hash into this Manifest's options
  #
  # @param [Hash, Manifest] opts The options to update
  #
  # @return [Manifest] The updated manifest
  def merge(opts)
    raise InvalidContentError.new unless(opts && (opts.is_a?(Hash) || opts.is_a?(Manifest)))

    @manifest_options.merge!(opts.to_h)

    self
  end

  # Creates a hash of the object's current state.
  #
  # @return [Hash] A hash representation of the Manifest object.
  def to_h
    @manifest_options
  end

  # Returns the contents of the object as a YAML string with the empty values removed.
  #
  # @return [String] The populated contents of the object as YAML string.
  def to_yaml
    self.to_h.compact.as_json.to_yaml
  end

end

class InvalidManifest < Manifest
  attr_reader :exception

  def initialize(exception)
    super({})

    @exception = exception
  end

  def valid?
    false
  end

  def save(path)
    false
  end
end

class MissingManifest < Manifest
  def valid?
    false
  end

  def exist?
    false
  end

  def save(path)
    false
  end
end

