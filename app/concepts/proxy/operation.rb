require File.expand_path('../operation', __FILE__)

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
    def process(params = {})
      model.requested_at = Time.now
      model.active = params[:active]
      model.save
    end

    private

    def model!(params)
      Proxy[params[:id]]
    end
  end
end
