module NginxStage
  class GeneratePun < Generate
    attr_reader :socket

    def initialize(opts)
      super(opts)
      @socket = opts.fetch(:socket, nil)
    end

    add_hook :require_socket do
      raise MissingOption, "missing option: --socket=SOCKET" unless socket
    end

    add_hook :validate_socket do
      raise InvalidSocket, "invalid socket: #{socket}" if File.exist?(socket)
    end

    add_hook :create_tmp_root do
      FileUtils.mkdir_p tmp_root
    end

    add_hook :create_log_root do
      FileUtils.mkdir_p log_root
    end

    add_hook :create_pid_root do
      FileUtils.mkdir_p NginxStage.pun_pid_root
    end

    add_hook :create_config do
      template "pun.conf.erb", File.join(NginxStage.pun_config_root, "#{user}.conf")
    end

    private
      def log_root
        File.join NginxStage.pun_log_root, user
      end

      def error_log_path
        File.join log_root, 'error.log'
      end

      def access_log_path
        File.join log_root, 'access.log'
      end

      def tmp_root
        File.join NginxStage.pun_tmp_root, user
      end

      def pid_path
        File.join NginxStage.pun_pid_root, "#{user}.pid"
      end
  end
end
