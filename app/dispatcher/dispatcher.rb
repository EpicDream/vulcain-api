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
  RUNNING_MESSAGE = File.read("#{Rails.root}/app/dispatcher/started.txt")
  
  def self.output msg, args={}
    output = case msg
    when :new_vulcain then "\nNew Vulcain running on host : #{args[:vulcain].host}"
    when :removed_vulcain then "\nVulcain on host : #{args[:vulcain].host} is dead !"
    when :ack_ping then "\nVulcain on host #{args[:vulcain].host} acknowledged ping - Status : #{args[:vulcain].idle ? 'idle' : 'busy'}"
    when :ping then "\nPing Vulcain on host : #{args[:vulcain].host}"
    when :running then RUNNING_MESSAGE + "\n\nRunning on : #{CONFIG['host']}" + "\nNumbers of vulcains : #{args[:pool_size]}"
    end
    $stdout << output
  end
end

require_relative 'amqp_runner'
require_relative 'pool'
require_relative 'worker'
require_relative 'loader'
require_relative 'exchangers'
require_relative 'message'