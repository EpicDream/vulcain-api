# encoding: utf-8
require "amqp"
require "json"

module Dispatcher
  CONFIG = YAML.load_file("#{Rails.root}/config/dispatcher.yml")[Rails.env]
  VULCAINS_QUEUE = "vulcains-queue" #/!\DO NOT CHANGE WITHOUT CHANGE ON VULCAIN
  LOGGING_QUEUE = "logging-queue" #/!\DO NOT CHANGE WITHOUT CHANGE ON VULCAIN
  API_QUEUE = "api-queue"
  VULCAIN_QUEUE = lambda { |vulcain_id| "vulcain-#{vulcain_id}" }
end

require_relative 'amqp_runner'
require_relative 'vulcain_pool'
require_relative 'worker'
require_relative 'controller'
require_relative 'shopelia_callback'
require_relative 'loader'