require File.expand_path('../config/environment', __FILE__)

class App < Sinatra::Base
  configure do
    enable :logging
  end

  configure :development do
    register Sinatra::Reloader
    also_reload File.expand_path('../concepts/**/*.rb', __FILE__)
  end

  get '/' do
    Proxy::Request.run(params) do |op|
      p op
    end
  end
end
