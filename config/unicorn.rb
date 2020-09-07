worker_processes 3
timeout 480
preload_app true
working_directory '/srv/www/apps/depot/current'
shared_directory = '/srv/www/apps/depot/shared'
listen "#{shared_directory}/tmp/sockets/unicorn.sock", :backlog => 64
pid "#{shared_directory}/tmp/pids/unicorn.pid"
stderr_path "#{shared_directory}/log/unicorn.stderr.log"
stdout_path "#{shared_directory}/log/unicorn.stdout.log"

before_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end

  sleep 1
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = ENV['REDIS_URI']
    Rails.logger.info('Connected to Redis')
  end
end