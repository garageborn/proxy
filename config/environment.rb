require 'sinatra'
require 'sinatra/reloader'

require 'active_support/all'
require 'addressable'
require 'httparty'
require 'memoist'
require 'retries'
require 'thread/pool'
require 'logger'

require 'trailblazer'
require 'trailblazer/operation'
require 'trailblazer/operation/model'

Dir.glob(File.expand_path('../initializers/**/*.rb', __FILE__)).each { |f| require f }
Dir.glob(File.expand_path('../../app/**/*.rb', __FILE__)).each { |f| require f }
Dir.glob(File.expand_path('../../lib/*.rb', __FILE__)).each { |f| require f }
Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__)).each { |f| require f }
