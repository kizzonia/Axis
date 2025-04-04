if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDISCLOUD_URL'] }
#     config.dead_letter_queues = 1
# config.dead_letter_max_retries = 3
#     config.server_middleware do |chain|
#     chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 3
#
#   end

  end


  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDISCLOUD_URL'] }
  end
else
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

end
