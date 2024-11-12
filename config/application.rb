require_relative "boot"
require "rails/all"
require 'redis'
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
    config.load_defaults 7.0
    $redis = Redis.new(url: 'redis://redis:6379') 
  end
end
