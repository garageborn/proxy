class Request
  class Logger
    extend Memoist

    def info(payload)
      return debug_log(:info, payload) if Sinatra::Base.development?
      logger.info(payload)
    end

    def error(payload)
      return debug_log(:error, payload) if Sinatra::Base.development?
      logger.info(payload)
    end

    private

    def logger
      if Sinatra::Base.production? && ENV['LOGGLY_TOKEN'].present?
        Logglier.new(
          "https://logs-01.loggly.com/inputs/#{ ENV['LOGGLY_TOKEN'] }/tag/proxy/",
          threaded: false,
          format: :json
        )
      else
        ::Logger.new("#{ Sinatra::Base.root }/log/proxy.log")
      end
    end

    def debug_log(type, payload)
      action = payload.delete(:action)
      payload[:exception].try(:delete, :backtrace)
      logger.send(type, "Proxy.#{ action } (#{ type }): #{ payload }")
    end

    memoize :logger
  end
end
