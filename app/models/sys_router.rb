class SysRouter < AweSim::Router
  # given app string "dashboard"
  # return url for app to access
  # FIXME: we should derive this from the nginx_stage gem
  def url_for_dev_app(app)
    raise "sys owner has shared apps only"
  end

  # given app string "dashboard"
  # and owner "efranz" return the url
  # FIXME: we could have /pun/sys be /pun/#{user} and then use the
  # nginx_config to determine whether the apps are user specific or fixed
  # deployment locations so that if later we had a /pun/totalsim that would
  # be fixed like /pun/sys but separate from a user's shared apps i.e. /pun/usr
  # or better... each router is for a single set of apps.
  # So instead of having a router define both shared and dev apps, you have 2
  # routers: one for user shared apps, one for dev apps, one for system
  # installed apps. This is actually a better approach
  def url_for_shared_app(app)
    "/pun/sys/#{app}"
  end

  # FIXME: to make this "relative to the dashboard deployment"
  # we could just specify the "shared apps path" as being the parent
  # directory of the Rails.root directory for the dashboard
  def shared_apps_path
    "/var/www/ood/apps/sys"
  end

  def dev_apps_path
    raise "sys owner has shared apps only"
  end

  def setup_access_to_apps_of(user: nil)
    # nothing to do here!
  end
end
