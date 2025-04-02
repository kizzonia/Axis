web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 5 -q transactions -q notifications -q default -q mailers
release: bundle exec rails db:migrate
