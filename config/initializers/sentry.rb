require 'raven'

if Sinatra::Base.production?
  Raven.configure do |config|
    config.dsn = ENV.fetch('PROXY_SENTRY_DSN')
    config.environments = %w(production)
    config.tags = { environment: Sinatra::Base.environment }
    config.processors = [Raven::Processor::SanitizeData]
    config.async = lambda do |event|
      Thread.new { Raven.send(event) }
    end
  end
end
