require File.expand_path('../config/environment', __FILE__)

class App < Sinatra::Base
  configure do
    enable :logging
  end

  configure :development do
    register Sinatra::Reloader
    also_reload File.expand_path('../concepts/**/*.rb', __FILE__)
  end

  configure :production do
    use Raven::Rack
  end

  %i(get post put).each do |method|
    send(method, '/') do
      options = params.merge(method: method)
      Proxy::Request.run(options) do |op|
        headers op.model.request.headers
        body op.model.request.body
      end
    end
  end
end
