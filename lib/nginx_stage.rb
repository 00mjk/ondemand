require_relative "nginx_stage/version"
require_relative "nginx_stage/configuration"
require_relative "nginx_stage/errors"
require_relative "nginx_stage/generate"
require_relative "nginx_stage/generate_pun"
require_relative "nginx_stage/generate_app"
require_relative "nginx_stage/application"

module NginxStage
  def self.root
    File.dirname __dir__
  end

  extend Configuration
end
