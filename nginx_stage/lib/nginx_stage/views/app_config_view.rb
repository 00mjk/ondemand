module NginxStage
  # A view used as context for the app config ERB template file
  module AppConfigView
    # The URI used to access the app from the browser
    # @return [String] the app URI
    def app_request_uri
      "#{sub_uri}#{NginxStage.app_request_uri(env: env, owner: owner, name: name)}"
    end

    # Path to the app root on the local filesystem
    # @return [String] path to app root
    def app_root
      NginxStage.app_root(env: env, owner: owner, name: name)
    end

    # The Passenger environment to run app under
    # @return [String] Passenger app environment
    def app_passenger_env
      NginxStage.app_passenger_env(env: env, owner: owner, name: name)
    end

    # Passenger passenger_stat_throttle_rate for reducing the number of checks
    # of restart.txt file in an app to be on every request only in development,
    # and every 2 minutes otherwise.
    #
    # @return [Integer] stat throttle rate
    def app_passenger_stat_throttle_rate
      if app_passenger_env == "development"
        0
      else
        120
      end
    end

    # The token used to identify an app
    # @return [String] unique app token
    def app_token
      NginxStage.app_token(env: env, owner: owner, name: name)
    end

    # Internal URI used to access filesystem from apps
    # @return [String] the filesystem URI
    def sendfile_uri
      NginxStage.pun_sendfile_uri
    end

    # Path to the filesystem root where files are served from
    # NB: Need to use a regular expression for user as this will be in a global
    # app config that all users share
    # @return [String] path to filesystem root
    def sendfile_root
      NginxStage.pun_sendfile_root(user: "[\w-]+")
    end
  end
end
