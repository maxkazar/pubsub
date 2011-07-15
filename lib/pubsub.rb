require "ruby_events"
require File.join(File.dirname(__FILE__), "pubsub/pubsub.rb")

module DigitalPro
  module Events
    module PubSub
      def subscribe(channel, procs = nil, &block)
        logger.info "Subscribe #{self.class.name} to #{channel}"

        PubSub.events.listen channel, procs, &block

        procs_collected = []
        if procs.respond_to?(:each) && procs.respond_to?(:to_a)
          procs_collected += procs.to_a
        elsif procs
          procs_collected << procs
        end
        procs_collected << block if block

        channel_handlers[channel] ||= []
        channel_handlers[channel] += procs_collected
      end

      def unsubscribe(channel=nil, proc = nil)
        # unsubscribe from all object channels
        unless channel
          channel_handlers.each_key{ |channel_name| unsubscribe channel_name}
          return
        end

        if proc
          logger.info "Unsubscribe #{self.class.name} to #{channel}"
          PubSub.events.remove channel, proc
          channel_handlers[channel].delete_if {|stored_event| stored_event == proc} if channel_handlers.include? channel
        else
          channel_handlers[channel].each { |proc_handler| unsubscribe channel, proc_handler} if channel_handlers.include? channel
        end
      end

      def publish(channel, *args)
        logger.info "Publish #{self.class.name} to #{channel} with #{args.to_s}"

        channel.sub_before "/" do |sub_channel|
          PubSub.events.fire sub_channel, *args
        end
        PubSub.events.fire "*", *args
      end

      protected

      def channel_handlers
        @channel_handlers ||= {}
      end

      def PubSub.events
        @@events ||= RubyEvents::Events.new(self)
      end

    end
  end
end
