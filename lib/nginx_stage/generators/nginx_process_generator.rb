module NginxStage
  # This generator generates/controls the per-user NGINX process.
  class NginxProcessGenerator < Generator
    desc 'Generate/control a per-user nginx process'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To stop Bob's nginx process:

            nginx_stage nginx --user=bob --signal=stop

        which sends a `stop` signal to Bob's per-user NGINX process.

        If `--skip-nginx` is supplied it returns the system-level command
        that would have been called.
    EOF

    # Accepts `user` as an option and validates user
    add_user_support

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # @!method signal
    #   The signal to send to the per-user NGINX process
    #   @return [String] nginx signal
    add_option :signal do
      {
        opt_args: ["-s", "--signal=SIGNAL", NginxStage.nginx_signals, "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}"],
        default: nil
      }
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    add_hook :exec_nginx do
      exec([NginxStage.nginx_bin, "nginx: #{user}"], *NginxStage.nginx_args(user: user, signal: signal)) unless skip_nginx
    end

    # If skip nginx, then return nginx command
    add_hook :return_nginx_cmd do
      "#{NginxStage.nginx_bin} #{NginxStage.nginx_args(user: user, signal: signal).join(' ')}"
    end
  end
end
