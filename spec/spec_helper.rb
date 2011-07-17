require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'pubsub'

logger.level = Logger::WARN

module PubSub
  PubSub.events.class.class_eval do
    def events_collection
      @events
    end
  end
end

class Publisher
  include PubSub
end

class Subscriber
  include PubSub

  def listener(message = nil)
    logger.info "listener_with_stop"
  end

  def listener1(message = nil)
  end

  def listener_with_stop(message = nil)
    PubSub.stop
  end
end