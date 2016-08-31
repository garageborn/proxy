require 'raven'

PROXY_SENTRY_DSN = ENV['PROXY_SENTRY_DSN'].freeze
if PROXY_SENTRY_DSN
  Raven.configure do |config|
    config.async = lambda do |event|
      Thread.new { Raven.send(event) }
    end
    config.dsn = PROXY_SENTRY_DSN
    config.environments = %w(production)
    config.excluded_exceptions << 'Rack::Timeout::RequestTimeoutException'
    config.processors = [Raven::Processor::SanitizeData]
    config.tags = { environment: Sinatra::Base.environment }
  end
end
