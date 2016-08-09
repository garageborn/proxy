require 'raven'

if Sinatra::Base.production?
  Raven.configure do |config|
    config.server = ENV.fetch('PROXY_SENTRY_DNS')
    config.tags = { environment: Sinatra::Base.environment }
    config.processors = [Raven::Processor::SanitizeData]
    config.async = lambda do |event|
      Thread.new { Raven.send(event) }
    end
  end
end
