require 'sinatra'
require 'memoist'
require 'httparty'

require 'trailblazer'
require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'dry-validation'
require 'reform'
require 'reform/form/dry'

Reform::Contract.class_eval do
  feature Reform::Form::Dry
end

require 'sinatra/reloader'
require File.expand_path('../../concepts/proxy/contract', __FILE__)
require File.expand_path('../../concepts/proxy/operation', __FILE__)
