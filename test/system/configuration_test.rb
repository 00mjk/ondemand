require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  #FIXME: this approach is ugly and difficult to follow
  #
  # Marshaling the AppConfig doesn't work because the methods are evaluated when
  # you call them: AppConfig doesn't store data for most of its options.
  #
  # Using Bundler.with_clean_env to provide several unit tests, one for loading
  # dotenv, and one for Configuration.new once expected env is loaded, doesn't
  # let us test dataroot because of OodAppkit's approach to storing the dataroot
  # as an instance variable.
  #
  # One solution to clean up the below code would be to implement a
  # Configuration#to_h method.
  def runner(code, env: 'development', envvars: '')
    Tempfile.open('runnerbin') do |f|
      Bundler.with_clean_env do
        f.write(code)
        f.close
        `RAILS_ENV=#{env} #{envvars} bin/rails runner -e #{env} #{f.path}`
      end
    end
  end

  test "configuration defaults in development env" do
    assert Dir.glob(".env.local{.development,.production,}").none?, "these tests should not be run with a .env.local or .env.local.development or .env.local.production"

    config = Marshal.load(runner('puts Marshal.dump(OpenStruct.new(brand_bg_color: AppConfig.brand_bg_color, dataroot: AppConfig.dataroot, load_external_config: AppConfig.load_external_config?))'))

    assert_nil config.brand_bg_color
    assert_equal Rails.root.join("data").to_s, config.dataroot.to_s
    assert_equal false, config.load_external_config
  end

  test "loading custom OSC external config in production env" do
    config_root = Rails.root.join('config','examples','osc')
    config = Marshal.load(runner('puts Marshal.dump(OpenStruct.new(brand_bg_color: AppConfig.brand_bg_color, dataroot: AppConfig.dataroot, load_external_config: AppConfig.load_external_config?))', env: 'production', envvars: "OOD_APP_CONFIG_ROOT=#{config_root}"))

    assert_equal '#c8102e', config.brand_bg_color
    assert_equal File.expand_path("~/ondemand/data/sys/dashboard"), config.dataroot.to_s
    assert_equal true, config.load_external_config
  end

  test "loading custom AweSim external config in production env" do
    config_root = Rails.root.join('config','examples','awesim')
    config = Marshal.load(runner('puts Marshal.dump(OpenStruct.new(brand_bg_color: AppConfig.brand_bg_color, dataroot: AppConfig.dataroot, load_external_config: AppConfig.load_external_config?))', env: 'production', envvars: "OOD_APP_CONFIG_ROOT=#{config_root}"))

    assert_nil config.brand_bg_color
    assert_equal File.expand_path("~/awesim/data/sys/dashboard"), config.dataroot.to_s
    assert_equal true, config.load_external_config
  end

  test "disable app sharing with falsy env value" do
    Bundler.with_clean_env do
      # default is false
      config = Configuration.new
      assert_equal false, Configuration.new.app_sharing_enabled?, 'default app sharing enabled should be false'

      # enabling is true
      ENV['OOD_APP_SHARING'] = '1'
      assert_equal true, Configuration.new.app_sharing_enabled?, 'OOD_APP_SHARING=1 should result in app sharing enabled'

      # disabling with a falsy value is false
      ENV['OOD_APP_SHARING'] = '0'
      assert_equal false, Configuration.new.app_sharing_enabled?, 'OOD_APP_SHARING=0 should result in app sharing disabled'
    end
  end
end
