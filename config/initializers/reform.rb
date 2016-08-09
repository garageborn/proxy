require 'dry-validation'
require 'reform'
require 'reform/form/dry'

Reform::Contract.class_eval do
  feature Reform::Form::Dry
end
