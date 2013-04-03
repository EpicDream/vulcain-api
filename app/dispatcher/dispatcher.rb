# encoding: utf-8
require "amqp"
require "json"

module Dispatcher
  USER = "guest"
  PASSWORD = "guest"
  HOST = "127.0.0.1"
  VULCAINS_USER = "guest"
  VULCAINS_PASSWORD = "guest"
  Vulcain = Struct.new(:exchange, :id)
  
  VULCAINS_QUEUE = "vulcains-queue" #DO NOT CHANGE WITHOUT CHANGE ON VULCAIN
  API_QUEUE = "api-queue"
end

require_relative 'amqp_runner'
require_relative 'vulcain_pool'
require_relative 'exchanger'
require_relative 'worker'

Dispatcher::Worker.new.start



