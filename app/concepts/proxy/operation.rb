require File.expand_path('../contract', __FILE__)

class Proxy < Ohm::Model
  class Save < Trailblazer::Operation
    include Model
    contract Contract
    model Proxy, :create

    def process(params)
      validate(params[:proxy]) do
        contract.save
      end
    end

    private

    def model!(params)
      return ::Proxy.new if params[:proxy].blank?
      return ::Proxy.new(params) if params[:proxy][:host].blank?
      ::Proxy.with(:host, params[:proxy][:host]) || ::Proxy.new(params[:proxy])
    end
  end

  class Desactivate < Trailblazer::Operation
    def process(*)
      model.active = false
      model.save
    end

    private

    def model!(params)
      Proxy[params[:id]]
    end
  end

  class Touch < Trailblazer::Operation
    MAX_ERRORS = 10

    def process(params = {})
      model.requested_at = Time.now
      params[:active] ? model.errors = 0 : model.errors += 1
      model.active = model.errors < MAX_ERRORS
      model.save
    end

    private

    def model!(params)
      Proxy[params[:id]]
    end
  end
end
