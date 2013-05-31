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
  RUNNING_MESSAGE = File.read("#{Rails.root}/lib/ascii-art-texts/started.txt")
  RESTORING_POOL_MESSAGE = File.read("#{Rails.root}/lib/ascii-art-texts/restore.txt")
  
  def self.logs msg, args={}, console=true
    output = case msg
    when :new_vulcain then "\nNew Vulcain running : #{args[:vulcain].id}"
    when :removed_vulcain then "\nVulcain : #{args[:vulcain].id} : Ouch! a serial killer has killed me, life is short !"
    when :ack_ping then "\nVulcain #{args[:vulcain].id} acknowledged ping - Status : #{args[:vulcain].idle ? 'idle' : 'busy'}"
    when :idle then "\nVulcain #{args[:vulcain].id} Status : idle"
    when :ping then "\nPing Vulcain : #{args[:vulcain].id}"
    when :running 
      header = (RUNNING_MESSAGE if console) || ""
      header + "\n\nRunning on : #{CONFIG['host']}" + "\nNumbers of vulcains : #{args[:pool_size]}"
    when :restoring_pool then RESTORING_POOL_MESSAGE
    when :reload_vulcain then "\nReload Vulcain: #{args[:vulcain].id}"
    when :abort then "\nSaving my boys before i die , life is short...\n\n"
    end
    output.gsub!(/\n/, ' ') unless console
    output
  end
  
  def self.output msg, args={}
    Log.create({ admin_message:logs(msg, args, false) })
    $stdout << logs(msg, args)
  end
end

Dispatcher::CONFIG.merge!(VulcainApi::Application.config.dispatcher)

require_relative 'pool'
require_relative 'worker'
require_relative 'loader'
require_relative 'exchangers'
require_relative 'message'
require_relative 'supervisor'