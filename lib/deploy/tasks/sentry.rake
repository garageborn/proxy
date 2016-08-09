require 'httparty'

namespace :deploy do
  namespace :sentry do
    task :notify_deployment do
      current_revision = `cd ~/docker/repo && git log --pretty=format:'%h' -n 1`.chomp
      HTTParty.post(
        'https://app.getsentry.com/api/hooks/release/builtin/91298/e4efda3b50b201910ee45c91fa096482e2ed4feaac7b281e80044eb5243c1c1c/',
        body: {
          version: current_revision,
          ref: current_revision,
          url: "https://github.com/garageborn/proxy/commit/#{ current_revision }"
        }.to_json
      )
    end
  end
end

Rake::Task['deploy:run'].enhance(['deploy:sentry:notify_deployment'])
