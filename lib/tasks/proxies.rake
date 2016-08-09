namespace :proxies do
  namespace :import do
    desc 'Import GimmeProxy proxies'
    task gimme_proxy: :environment do
      Proxy::Source::GimmeProxy.instance.all.each do |proxy|
        ::Proxy::Save.run(proxy: {
          ip: proxy[:ip],
          port: proxy[:port],
          active: true
        })
      end
    end
  end
end
