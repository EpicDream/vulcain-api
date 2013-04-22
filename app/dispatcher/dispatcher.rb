# encoding: utf-8
# /!\ DO NOT CHANGE QUEUES NAMES WITHOUT CHANGE ON VULCAIN

require "amqp"
require "json"

module Dispatcher
  CONFIG = YAML.load_file("#{Rails.root}/config/dispatcher.yml")[Rails.env]
  VULCAINS_QUEUE = "vulcains-queue" 
  LOGGING_QUEUE = "logging-queue"
  ADMIN_QUEUE = "admin-queue"
  API_QUEUE = "api-queue"
  VULCAIN_QUEUE = lambda { |vulcain_id| "vulcain-#{vulcain_id}" }
  MESSAGES_VERBS = {:start => 'start'}
  MESSAGES_STATUSES = {:started => 'started', :reloaded => 'reloaded'}
  
end

require_relative 'amqp_runner'
require_relative 'vulcain_pool'
require_relative 'worker'
require_relative 'controller'
require_relative 'shopelia_callback'
require_relative 'loader'