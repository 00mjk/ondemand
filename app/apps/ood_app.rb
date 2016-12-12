class OodApp
  attr_reader :router
  delegate :owner, :caption, :type, :path, :name, :token, to: :router

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

  def title
    manifest.name.empty? ? name.titleize : manifest.name
  end

  def url
    if manifest.url.empty?
      router.url
    else
      manifest.url % {
        app_type: type,
        app_owner: owner,
        app_name: name,
        app_token: token
      }
    end
  end

  def has_gemfile?
    path.join("Gemfile").file? && path.join("Gemfile.lock").file?
  end

  def category
    manifest.category.empty? ? router.category : manifest.category
  end

  def subcategory
    manifest.subcategory
  end

  def role
    manifest.role
  end

  def bundler_helper
    @bundler_helper ||= BundlerHelper.new(path)
  end

  def manifest
    @manifest ||= load_manifest
  end

  def icon_path
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
