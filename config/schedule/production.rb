env :PATH, ENV['PATH']

set :output, 'log/cron.log'
job_type :rake, "cd :path && :environment_variable=:environment bin/rake :task --silent :path/:output"

# Proxies
every 90.minutes do # 1.000 requests per 24 hours allowed, 60 requests per minute
  rake 'proxies:import:gimme_proxy'
end
