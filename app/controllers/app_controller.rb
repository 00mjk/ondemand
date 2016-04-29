class AppController < ApplicationController

  def show
    owner = params[:owner]
    app_name = params[:app_name]
    path = params[:path]

    initialize_app_access(owner, app_name, path)
    redirect_to app_url(owner, app_name, path)

  rescue AweSim::App::SetupScriptFailed => e
    #FIXME: should this be 500 error?
    @app_url = app_url(owner, app_name, path)
    @exception = e
    render "setup_failed"
  end

  private

  # initialize app and return the app_url to access
  def initialize_app_access(owner, app_name, path)
    router = ::AppRouter.for(owner)
    myrouter = ::AppRouter.new

    app = AweSim::App.at(path: router.path_for(app: app_name))

    # app doesn't exist or you do not have access:
    raise ActionController::RoutingError.new('Not Found') unless app


    # follow app owner and run setup - both idempotent actions that are safe to
    # run many times
    myrouter.setup_access_to_apps_of(user: owner)

    # run idempotent setup script to setup data for user and handle any errors
    app.run_setup_production
  end

  # get app_url for path to app
  def app_url(owner, app_name, path)
    router = ::AppRouter.for(owner)
    app_url = router.url_for(app: app_name)

    # if a path in the app is provided, append this to the URL
    if path
      app_uri = URI(app_url)
      app_uri.path = Pathname.new(app_uri.path).join(path).to_s
      app_url = app_uri.to_s
    end

    app_url
  end
end
