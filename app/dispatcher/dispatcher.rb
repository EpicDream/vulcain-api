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
  MESSAGES_VERBS = {
    :ask => 'ask', :message => 'message', :terminate => 'success',
    :assess => 'assess', :failure => 'failure', :start => 'start', ping:'ping'
  }
  ADMIN_MESSAGES_STATUSES = {
    started:'started', reloaded:'reloaded', abort:'abort', failure:'failure', terminate:'terminate',
    reload:'reload', ack_ping:'ack_ping'
  }
  
  STATUSES_CODE = {:no_idle => 'no_idle'}
end

require_relative 'amqp_runner'
require_relative 'pool'
require_relative 'worker'
require_relative 'controller'
require_relative 'shopelia_callback'
require_relative 'loader'
require_relative 'exchangers'