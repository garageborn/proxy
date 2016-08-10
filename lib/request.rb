class Request
  extend Memoist
  autoload :Logger, './lib/request/logger'

  RESCUE_FROM = [
    EOFError,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Net::HTTPRetriableError,
    Net::HTTPServerException,
    Timeout::Error
  ].freeze
  DEFAULT_TIMEOUT = 10
  MAX_RETRIES = 7

  attr_accessor :url, :options, :verb, :max_tries, :current_proxy, :request, :request_id

  def initialize(params = {})
    @url = params[:url]
    @options = { timeout: DEFAULT_TIMEOUT }.merge(params[:options].to_h)
    @verb = params[:verb] || :get
    @max_tries = params[:max_tries] || MAX_RETRIES
    @request_id = SecureRandom.uuid
  end

  def run
    with_retries(max_tries: max_tries, handler: retry_handler, rescue: RESCUE_FROM) do |attempt|
      set_options!(attempt)
      self.request = call
    end
  end

  private

  def call
    logging do
      HTTParty.send(verb, url, options).tap do |request|
        touch_current_proxy!(request.success?)
        raise Errno::ECONNREFUSED unless request.success?
      end
    end
  end

  def set_options!(attempt)
    if attempt == MAX_RETRIES || current_proxy.blank?
      options.delete(:http_proxyaddr)
      options.delete(:http_proxyport)
    else
      options[:http_proxyaddr] = current_proxy.ip.to_s
      options[:http_proxyport] = current_proxy.port
    end
  end

  def current_proxy
    @current_proxy ||= Proxy.sample
  end

  def reload_current_proxy!
    @current_proxy = nil
  end

  def touch_current_proxy!(active)
    return unless current_proxy.present?
    Proxy::Touch.run(id: current_proxy.id, active: active)
  end

  def retry_handler
    proc do
      Proxy::Desactivate.run(id: current_proxy.id) if current_proxy.present?
      reload_current_proxy!
    end
  end

  def logging
    payload = { action: :request, request_id: request_id }.merge(options)
    logger.info payload.merge(status: :pending)
    response = yield
    logger.info payload.merge(status: :success)
    response
  rescue StandardError => e
    logger.error payload.merge(
      status: :error,
      exception: { message: e.message, backtrace: e.backtrace.first(10).join("\n") }
    )
    raise(e)
  end

  def logger
    ::Request::Logger.new
  end

  memoize :retry_handler, :logger
end
