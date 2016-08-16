require 'bundler/setup'
require File.expand_path('../app', __FILE__)

use Raven::Rack
use Rack::Timeout, service_timeout: REQUEST_TIMEOUT
run App
