# encoding: utf-8
# /!\ DO NOT CHANGE QUEUES NAMES WITHOUT CHANGE ON VULCAIN

require "amqp"
require "json"

module Dispatcher
  CONFIG = YAML.load_file("#{Rails.root}/config/dispatcher.yml")[Rails.env]
  VULCAINS_QUEUE = "vulcains-queue" 
  LOGGING_QUEUE = "logging-queue"
  ADMIN_QUEUE = "admin-queue"
  RUN_API_QUEUE = "run-api-queue"
  ANSWER_API_QUEUE = "answer-api-queue"
  VULCAIN_QUEUE = lambda { |vulcain_id| "vulcain-#{vulcain_id}" }
end

require_relative 'amqp_runner'
require_relative 'pool'
require_relative 'worker'
require_relative 'loader'
require_relative 'exchangers'
require_relative 'message'