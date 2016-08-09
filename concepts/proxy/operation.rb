class Proxy
  class Operation < Trailblazer::Operation
    include Model
    model Proxy
  end

  class Save < Operation
    contract Contract
    action :create

    def process(params)
      validate(params[:proxy]) do
        contract.save
      end
    end

    private

    def model!(params)
      return ::Proxy.new if params[:proxy].blank?
      return ::Proxy.find(params[:proxy][:id]) if params[:proxy][:id].present?
      ::Proxy.where(ip: params[:proxy][:ip], port: params[:proxy][:port]).first_or_initialize
    end
  end

  class Desactivate < Operation
    action :find

    def process(*)
      model.update_attributes(active: false)
    end
  end

  class Touch < Operation
    action :find

    def process(params = {})
      model.update_attributes(requested_at: Time.zone.now, active: params[:active])
    end
  end
end
