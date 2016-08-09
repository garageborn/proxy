class Proxy
  class Request
    extend Memoist

    RESCUE_FROM = [Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError, Timeout::Error].freeze
    DEFAULT_TIMEOUT = 10
    MAX_RETRIES = 7

    attr_accessor :url, :options, :method, :max_tries, :current_proxy, :request_id

    def self.run(url, options: {}, method: :get, max_tries: MAX_RETRIES)
      new(url, options: options, method: method, max_tries: max_tries).run
    end

    def initialize(url, options:, method:, max_tries:)
      @url = url
      @options = options
      @method = method
      @max_tries = max_tries
      @request_id = SecureRandom.uuid
    end

    def run
      with_retries(max_tries: max_tries, handler: retry_handler, rescue: RESCUE_FROM) do |attempt|
        set_options!(attempt)
        call(method, url, options)
      end
    end

    private

    def call(method, url, options)
      logging do
        HTTParty.send(method, url, options).tap do |request|
          touch_current_proxy!(request.success?)
          raise Errno::ECONNREFUSED unless request.success?
        end
      end
    end

    def set_options!(attempt)
      options[:timeout] ||= DEFAULT_TIMEOUT

      if attempt == MAX_RETRIES || current_proxy.blank?
        options.delete(:http_proxyaddr)
        options.delete(:http_proxyport)
      else
        options[:http_proxyaddr] = current_proxy.ip.to_s
        options[:http_proxyport] = current_proxy.port
      end

      options
    end

    def current_proxy
      @current_proxy ||= ::Proxy.sample
    end

    def reload_current_proxy!
      @current_proxy = nil
    end

    def touch_current_proxy!(active)
      ::Proxy::Touch.run(id: current_proxy.id, active: active)
    end

    def retry_handler
      proc do
        ::Proxy::Desactivate.run(id: current_proxy.id)
        reload_current_proxy!
      end
    end

    def logging
      payload = { type: :info, action: :request, request_id: request_id }.merge(options)
      instrument_log payload.merge(status: :pending)
      response = yield
      instrument_log payload.merge(status: :success)
      response
    rescue StandardError => e
      instrument_log payload.merge(
        type: :error,
        status: :error,
        exception: { message: e.message, backtrace: e.backtrace.first(10).join("\n") }
      )
      raise(e)
    end

    def instrument_log(payload)
      # ActiveSupport::Notifications.instrument('proxy.logger', payload)
    end

    memoize :retry_handler
  end
end
