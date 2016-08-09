class Proxy
  class Contract < Reform::Form
    property :ip
    property :port
    property :active
    property :requested_at

    validation do
      required(:active).filled
      required(:ip).filled
      required(:port).filled
    end
  end
end
