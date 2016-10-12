class OodApp
  attr_reader :router
  delegate :owner, :url, :type, :path, to: :router

  PROTECTED_NAMES = ["shared_apps", "cgi-bin", "tmp"]

  def accessible?
    path.executable? && path.readable?
  end
  alias_method :rx?, :accessible?

  def valid_dir?
    path.directory? &&
    ! self.class::PROTECTED_NAMES.include?(path.basename.to_s) &&
    ! path.basename.to_s.start_with?(".")
  end

  def initialize(router)
    @router = router
  end

  def name
    path.basename.to_s
  end

  def title
    manifest.name.empty? ? name.titleize : manifest.name
  end

  # returns app group title or nil if no group
  def group
    # TODO: delegate to manifest(?)
  end

  def has_gemfile?
    path.join("Gemfile").file? && path.join("Gemfile.lock").file?
  end

  def bundler_helper
    @bundler_helper ||= BundlerHelper.new(path)
  end

  def manifest
    @manifest ||= load_manifest
  end

  def icon_path
    # TODO:
    # maybe support icon in different formats? optional.
    # path.children.select { |p| p.basename.to_s =~ /icon\.(png|jpg|svg)/  }.first
    path.join("icon.png")
  end

  class SetupScriptFailed < StandardError; end
  # run the production setup script for setting up the user's
  # dataroot and database for the current app, if the production
  # setup script exists and can be executed
  def run_setup_production
    Bundler.with_clean_env do
      setup = "./bin/setup-production"
      Dir.chdir(path) do
        if File.exist?(setup) && File.executable?(setup)
          output = `bundle exec #{setup} 2>&1`
          unless $?.success?
            msg = "Per user setup failed for script at #{path}/#{setup} "
            msg += "for user #{Etc.getpwuid.name} with output: #{output}"
            raise SetupScriptFailed, msg
          end
        end
      end
    end
  end

  private

  def load_manifest
    default = path.join("manifest.yml")
    alt = path.dirname.join("#{path.basename}.yml")
    alt.exist? ? Manifest.load(alt) : Manifest.load(default)
  end
end
