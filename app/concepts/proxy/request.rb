class Proxy < Ohm::Model
  class Request < Trailblazer::Operation
    contract do
      property :url
      property :verb, default: 'post'
      property :options

      validation do
        required(:url).filled
        required(:url).value(format?: URI.regexp)
      end
    end

    def process(params = {})
      validate(params) do
        model.run
      end
    end

    private

    def model!(params = {})
      ::Request.new(params)
    end
  end
end
