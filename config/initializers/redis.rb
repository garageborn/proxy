require 'redis'
require 'redis-namespace'
require 'ohm'
require 'ohm/contrib'

REDIS_URL = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379').freeze
REDIS_NAMESPACE = ENV['PROXY_REDIS_NAMESPACE'].freeze
REDIS_TIMEOUT = ENV.fetch('REDIS_TIMEOUT', 10_000).to_i * 1_000 # microseconds

redis_connection = Redic.new(REDIS_URL, REDIS_TIMEOUT)
if REDIS_NAMESPACE
  Ohm.redis = Redis::Namespace.new(
    REDIS_NAMESPACE.to_sym,
    redis: redis_connection,
    warning: false
  )
else
  Ohm.redis = redis_connection
end
