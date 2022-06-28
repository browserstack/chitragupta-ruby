require "chitragupta/version"
require "securerandom"
require "chitragupta/constants"
require "chitragupta/categories"
require "chitragupta/format_versions"
require "chitragupta/util"
require "chitragupta/json_log_formatter"
require "chitragupta/logger"
require 'rack'
require 'json'

module Chitragupta
    extend self
    attr_accessor :payload

    self.payload = {}

    class CommonLoggerLog
        def initialize(app, logger)
            @app, @logger = app, logger
            @logger.formatter = Chitragupta::JsonLogFormatter.new
        end
        
        def call(env)
            began_at = Time.now
            Chitragupta.payload['rack_logger'] = env.to_json
            if env['REQUEST_METHOD'] == "GET"
                Chitragupta.payload['input_params'] = env['QUERY_STRING']
            else
                Chitragupta.payload['input_params'] = env['rack.input'].read
            end
            status, header, body = @app.call(env)
            body = Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
            [status, header, body]
        end

        def log(env, status, response_headers, began_at)
            now = Time.now
            server_log = {}
            server_log[:status] = status.to_s[0..3]
            server_log[:duration] = now - began_at
            server_log[:meta] = {}
            server_log[:meta][:file] = @logger.instance_variable_get(:@logdev).filename rescue nil
            server_log[:log] = {}
            @logger.info(server_log)
        end
    end

    def get_unique_log_id
        return SecureRandom.uuid
    end
end
