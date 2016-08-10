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
      active_proxy = active.sort(by: :requested_at, order: 'DESC', limit: [0, 10]).sample
      return active_proxy if active_proxy.present?
      all.sort(by: :requested_at, order: 'DESC', limit: [0, 50]).sample
    end
  end
end
