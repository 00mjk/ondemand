class OodApp
  attr_reader :router

  PROTECTED_NAMES = ["shared_apps", "cgi-bin", "tmp"]

  # FIXME: still returns nil sometimes yuck
  # def self.at(path: path, router: PathRouter.new)
  #   app = self.new(path: path, router: router)
  #   app if app.valid_dir? && (app.accessible? || app.manifest.exist?)
  # end

  # def self.all_at(path: path, router: PathRouter.new)
  #   Dir.glob("#{path}/**").sort.reduce([]) do |apps, appdir|
  #     app = self.at(path: appdir, router: router)
  #     apps << app unless app.nil?
  #     apps
  #   end
  # end

  # FIXME: should we be making clear which methods of App
  # require accessible? true i.e. rx access to 
  def accessible?
    path.executable? && path.readable?
  end
  alias_method :rx?, :accessible?

  def valid_dir?
    (path.directory? &&
      ! self.class::PROTECTED_NAMES.include?(path.basename.to_s) &&
      path.extname != ".git")
  end

  def initialize(router)
    @router = router
  end

  def name
    path.basename
  end

  # router based methods
  # #######################################################

  def owner
    router.owner
  end

  def url
    router.url
  end

  # end router based methods
  # #######################################################

  def title
    name.titlelize
  end

  def path
    router.path
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
