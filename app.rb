require File.expand_path('../config/environment', __FILE__)

class App < Sinatra::Base
  configure do
    enable :logging
  end

  configure :development do
    register Sinatra::Reloader
    also_reload File.expand_path('../app/**/*.rb', __FILE__)
    also_reload File.expand_path('../lib/**/*.rb', __FILE__)
  end

  %i(get post put head).each do |method|
    send(method, '/') do
      options = params.merge(method: method).deep_symbolize_keys
      return halt(200, {}, nil)
      # Proxy::Request.run(options) do |op|
      #   return halt op.model.response
      # end
      return halt 400
    end
  end
end
