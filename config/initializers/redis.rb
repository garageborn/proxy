require 'redis'
require 'redis-namespace'
require 'ohm'
require 'ohm/contrib'

REDIS_URL = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379')
REDIS_NAMESPACE = "proxy_#{ Sinatra::Base.environment }".to_sym

redis_connection = Redic.new(REDIS_URL)
namespaced_redis = Redis::Namespace.new(REDIS_NAMESPACE, redis: redis_connection, warning: false)
Ohm.redis = namespaced_redis
