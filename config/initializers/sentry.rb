require 'raven'
PROXY_SENTRY_DSN = ENV['PROXY_SENTRY_DSN'].freeze

if PROXY_SENTRY_DSN.present?
  Raven.configure do |config|
    config.dsn = PROXY_SENTRY_DSN
  end
end
