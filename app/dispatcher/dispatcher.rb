# encoding: utf-8
require "amqp"
require "json"

module Dispatcher
  USER = "guest"
  PASSWORD = "guest"
  HOST = "178.33.60.114"
  VULCAIN_HOST = "178.33.60.114"
  VULCAINS_USER = "guest"
  VULCAINS_PASSWORD = "guest"
  Vulcain = Struct.new(:exchange, :id)
  
  VULCAINS_QUEUE = "vulcains-queue" #DO NOT CHANGE WITHOUT CHANGE ON VULCAIN
  API_QUEUE = "api-queue"
end

require_relative 'amqp_runner'
require_relative 'vulcain_pool'
require_relative 'worker'
require_relative 'controller'
require_relative 'shopelia_callback'