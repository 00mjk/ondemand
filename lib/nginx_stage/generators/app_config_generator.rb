module NginxStage
  # This generator stages and generates the NGINX app config. It is also
  # responsible for reloading the per-user NGINX process after updating the app
  # config.
  class AppConfigGenerator < Generator
    # @!method user
    #   The user that the per-user NGINX will run as
    #   @return [User] the user of the nginx process
    #   @raise [MissingOption] if user isn't supplied
    add_option :user do
      raise MissingOption, "missing option: --user=USER"
    end

    # @!method skip_nginx
    #   Whether we skip calling the NGINX process
    #   @return [Boolean] if true, skip calling the nginx binary
    add_option :skip_nginx, false

    # @!method sub_uri
    #   The sub-uri that distinguishes the per-user NGINX process
    #   @example An app is requested through '/pun/shared/user/appname/...'
    #     sub_uri #=> "/pun"
    #   @return [String] the sub-uri for nginx
    add_option :sub_uri, nil

    # @!method sub_request
    #   The remainder of the request after the sub-uri used to determine the
    #   environment and app
    #   @example An app is requested through '/pun/shared/user/appname/...'
    #     sub_request #=> "/shared/user/appname/..."
    #   @return [String] the remainder of the request after sub-uri
    #   @raise [MissingOption] if sub_request isn't supplied
    add_option :sub_request do
      raise MissingOption, "missing option: --sub-request=SUB_REQUEST"
    end

    # Parse the sub_request for the environment, owner, and app name
    add_hook :parse_sub_request do
      info = NginxStage.parse_app_request(request: sub_request)
      @app_env   = info.fetch(:env)
      @app_owner = User.new info.fetch(:owner, user.name)
      @app_name  = info.fetch(:name, nil)
    end

    # Validate that the path to the app exists on the local filesystem
    add_hook :validate_app_root do
      raise InvalidRequest, "invalid app root: #{app_root}" unless File.directory?(app_root)
    end

    # Generate the NGINX app config from the 'app.conf.erb' template
    add_hook :create_config do
      template "app.conf.erb", app_config_path
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    add_hook :exec_nginx do
      exec(NginxStage.nginx_cmd(user: user, signal: :reload)) unless skip_nginx
    end

    # If we skip nginx, then return the path to the generated NGINX app config
    add_hook :return_app_config_path do
      app_config_path
    end

    private
      # NGINX app config path
      def app_config_path
        NginxStage.app_config_path(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # Path to the app root on the local filesystem
      def app_root
        NginxStage.get_app_root(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # The URI used to access the app from the browser
      def app_uri
        app_request = NginxStage.get_app_request(env: @app_env, owner: @app_owner, name: @app_name)
        "#{sub_uri}#{app_request}"
      end

      # The Passenger environment to run app under
      def env
        @app_env == :dev ? "development" : "production"
      end
  end
end
