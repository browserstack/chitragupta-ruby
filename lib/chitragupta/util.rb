require "socket"
require "json"

module Chitragupta
  module Util
    extend self

    def sanitize_keys(log_level, timestamp, message)
      data = initialize_data(message)

      data[:log][:level] = log_level
      data[:meta][:timestamp] = timestamp

      return "#{data.to_json.to_s}\n"
    end

    def called_as_rack_server?
      # Check if its called using rack up and Rack server is defined to log for rack
      return Gem.loaded_specs.has_key?('thin')
    end

    def called_as_sidekiq?
      return Sidekiq.server? && true || false
    end

    def called_as_rake?
      return File.basename($PROGRAM_NAME) == 'rake'
    end

    def called_as_console?
      return defined?(Rails::Console) && true || false
    end

    private
    def populate_server_data(data, message)
      current_payload = JSON.parse(Chitragupta.payload["rack_logger"])
      data[:data][:request] = {}
      data[:data][:response] = {}
      data[:data][:request][:method] = current_payload["REQUEST_METHOD"]
      data[:data][:request][:endpoint] = current_payload["REQUEST_PATH"]
      data[:data][:request][:ip] = current_payload["REMOTE_ADDR"]
      data[:data][:request][:id] = current_payload["REQUEST_ID"] rescue nil #TBD
      data[:data][:request][:user_id] = message[:user_id] rescue nil #TBD
      data[:data][:request][:params] = Chitragupta.payload["input_params"].to_s
      data[:data][:request][:headers] = nil # couldn't find where to put in headers?

      data[:data][:response][:status] = message[:status] rescue nil
      data[:data][:response][:duration] = message[:duration] rescue nil

      data[:meta][:format][:category] = Chitragupta::Categories::SERVER
      data[:meta][:format][:version] = Chitragupta::FormatVersions::SERVER
      data[:meta][:host] = Socket.gethostname #TBD

      if not data[:meta].has_key?(:component) and data[:meta][:component].nil?
        data[:meta][:component] = Chitragupta.payload['component'] rescue nil
      end
      if not data[:meta].has_key?(:application) and data[:meta][:application].nil?
        data[:meta][:application] = Chitragupta.payload['application'] rescue nil
      end
      if not data[:meta].has_key?(:team) and data[:meta][:team].nil?
        data[:meta][:team] = Chitragupta.payload['team'] rescue nil
      end
      if not data[:meta].has_key?(:release_version)
        data[:meta][:release_version] = Chitragupta.payload['release_version'] rescue nil
      end

      data[:log][:id] ||= message["log_id"] rescue nil #TBD
      data[:log][:uuid] = Chitragupta.payload["sessionid"]
      if not data[:log].has_key?(:kind) and data[:log][:kind].nil?
        data[:log][:kind] = Chitragupta.payload['kind'] rescue nil
      end
      if not data[:log].has_key?(:dynamic_data) and data[:log][:dynamic_data].nil?
        data[:log][:dynamic_data] = Chitragupta.payload['dynamic_data'] rescue nil
      end
    end

    def populate_ruby_server_data(data, message)
      populate_server_data(data, message)
    end

    # This is not in use as of now
    def populate_task_data(data, message)
      data[:data][:name] = Rake.application.current_task
      data[:data][:execution_id] = Rake.application.execution_id

      data[:meta][:format][:category] = Chitragupta::Categories::PROCESS
      data[:meta][:format][:version] = Chitragupta::FormatVersions::PROCESS
      data[:meta][:host] = Socket.gethostname
    end

    # This is not in use as of now
    def populate_worker_data(data, message)
      data[:meta][:format][:category] = Chitragupta::Categories::WORKER
      data[:meta][:format][:version] = Chitragupta::FormatVersions::WORKER
      data[:meta][:host] = Socket.gethostname

      data[:data][:thread_id] = Chitragupta::Constants::THREAD_ID_PREFIX + Thread.current.object_id.to_s(36)
      if Thread.current[:sidekiq_context].nil?
        return
      end
      worker_name, job_id = Thread.current[:sidekiq_context][0].split
      data[:data][:job_id] = job_id
      data[:data][:worker_name] = worker_name
    end

    def initialize_data(message)
      data = {}
      data[:data] = {}

      if message.is_a?(Hash)
        data[:log] = message[:log] || {}
        data[:meta] = message[:meta] || {}
      else
        data[:log] = {}
        data[:meta] = {}
        data[:log][:dynamic_data] = message.is_a?(String) ? message : message.inspect if message
      end

      data[:meta][:format] ||= {}
      begin
        if called_as_rack_server?
          populate_ruby_server_data(data, message)
        elsif called_as_rake?
          populate_task_data(data, message)
        elsif called_as_sidekiq?
          populate_worker_data(data, message)
        end
      rescue; end
      return data
    end

  end
end
