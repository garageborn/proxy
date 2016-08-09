class Proxy < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Timestamps

  attribute :host
  attribute :active, Type::Boolean
  attribute :requested_at, Type::Time

  index :host
  index :active
  unique :host

  def ip
    return if host.blank?
    host.split(':').first
  end

  def port
    return if host.blank?
    host.split(':').last
  end

  class << self
    def active
      Proxy.find(active: true)
    end

    def sample
      sort_options = { by: :requested_at, order: 'DESC', limit: [0, 10] }
      active.sort(sort_options).sample || all.sort(sort_options).sample
    end
  end
end
