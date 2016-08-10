class Proxy
  module Source
    class GimmeProxy
      extend Memoist
      include Singleton

      GET_PROXY_URL = Addressable::URI.new(
        scheme: 'http',
        host: 'gimmeproxy.com',
        path: '/api/getProxy',
        query_values: {
          cookies: true,
          get: true,
          post: true,
          protocol: 'http',
          supportsHttps: true
        }
      ).to_s.freeze
      DEFAULT_RATE_LIMIT = 60
      DEFAULT_RATE_LIMIT_WINDOW = 1.minute.to_i
      MAX_RATE_LIMIT_WINDOW = 5.minutes.to_i
      MAX_RETRIES = 3
      RESCUE_FROM = ::Request::RESCUE_FROM

      attr_accessor :last_request

      def all
        return if proxies.size >= rate_limit
        (rate_limit - proxies.size).times { request_new_proxy }
        pool.shutdown
        proxies
      end

      private

      def request_new_proxy
        pool.process { new_proxy_proc.call }
      end

      def fetch_proxy!
        with_retries(max_tries: MAX_RETRIES, rescue: RESCUE_FROM) do
          sleep next_rate_limit_window if at_rate_limit?

          HTTParty.get(GET_PROXY_URL).tap do |request|
            raise Errno::ECONNREFUSED unless request.success?
          end
        end
      rescue *RESCUE_FROM
      end

      def new_proxy_proc
        proc do
          current_request = fetch_proxy!
          next if current_request.blank?
          add_proxy(
            ip: current_request.parsed_response['ip'],
            port: current_request.parsed_response['port']
          )
          @last_request = current_request
        end
      end

      def add_proxy(new_proxy)
        return if new_proxy[:ip].blank? || new_proxy[:port].blank?
        host = "#{ new_proxy[:ip] }:#{ new_proxy[:port] }"
        proxies.push(host) unless proxies.include?(host)
      end

      def at_rate_limit?
        return false if last_request.blank?
        last_request.code == 429
      end

      def rate_limit
        return DEFAULT_RATE_LIMIT if last_request.blank?
        last_request.headers['x-ratelimit-limit'].to_i || DEFAULT_RATE_LIMIT
      end

      def next_rate_limit_window
        return DEFAULT_RATE_LIMIT_WINDOW if last_request.blank?
        [last_request.headers['retry-after'].to_i, MAX_RATE_LIMIT_WINDOW].min
      end

      def proxies
        []
      end

      def pool
        Thread.pool(rate_limit)
      end

      memoize :proxies, :pool, :new_proxy_proc
    end
  end
end
