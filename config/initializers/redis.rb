require 'redis'
require 'redis-namespace'
require 'ohm'
require 'ohm/contrib'

REDIS_URL = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379')
REDIS_NAMESPACE = "proxy_#{ Sinatra::Base.environment }".to_sym
REDIS_TIMEOUT = ENV.fetch('REDIS_TIMEOUT', 10_000).to_i * 1_000 # microseconds

redis_connection = Redic.new(REDIS_URL, REDIS_TIMEOUT)
namespaced_redis = Redis::Namespace.new(REDIS_NAMESPACE, redis: redis_connection, warning: false)
Ohm.redis = namespaced_redis
