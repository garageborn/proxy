env :PATH, ENV['PATH']

set :output, 'log/cron.log'
job_type :rake, "cd :path && :environment_variable=:environment bin/rake :task --silent :path/:output"

# Proxies
every 1.hour do
  rake 'import:gimme_proxy'
end
