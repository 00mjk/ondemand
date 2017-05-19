class DashboardController < ApplicationController
  def index
    flash.now[:alert] = "OnDemand requires a newer version of the browser you are using. Current browser requirements include IE Edge, Firefox 19+, Chrome 34+, Safari 8+." unless view_context.browser.modern?
    flash.now[:alert] = "OnDemand is not yet optimized for mobile use." if view_context.browser.device.mobile?

    motd_file = MotdFile.new(ENV['MOTD_PATH'])
    case ENV['MOTD_FORMAT']
    when 'osc'
      @motd = MotdFormatterOsc.new(motd_file)
    when 'markdown'
      @motd = MotdFormatterMarkdown.new(motd_file)
    when 'rss'
      @motd = MotdFormatterRss.new(motd_file)
    else
      @motd = MotdFormatterPlaintext.new(motd_file)
    end
  end

  def logout
  end
end
