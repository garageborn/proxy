class Proxy < Ohm::Model
  class Contract < Reform::Form
    property :host
    property :active
    property :requested_at

    validation do
      required(:host).filled
      required(:active).filled
    end
  end
end
