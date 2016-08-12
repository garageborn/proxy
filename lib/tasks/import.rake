namespace :import do
  desc 'Import GimmeProxy proxies'
  task gimme_proxy: :environment do
    Proxy::Source::GimmeProxy.instance.all.each do |host|
      ::Proxy::Save.run(proxy: { host: host, active: true, errors: 0 })
    end
  end
end
