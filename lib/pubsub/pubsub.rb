require "ruby_events"
require File.join(File.dirname(__FILE__), "logger.rb")
require File.join(File.dirname(__FILE__), "string.rb")

module PubSub
  def subscribe(channel, procs = nil, &block)
    mutex.synchronize do
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
  end

  def unsubscribe(channel=nil, proc = nil)
    mutex.synchronize do
      unsubscribe_safe(channel, proc )
    end
  end

  def publish(channel, *args)
    mutex.synchronize do
      logger.info "Add to publish queue #{self.class.name} to #{channel} with #{args.to_s}"
      PubSub.queue.push({:sender => self, :channel => channel, :params => args})
      PubSub.thread.wakeup if PubSub.thread.status == "sleep"
      if PubSub.queue.count > PubSub.queue_size
        #puts "Mutex sleep, queue length #{PubSub.queue.count}"
        PubSub.waiting.push Thread.current
        mutex.sleep
      end

    end
  end

  def PubSub.run
    @@stopped = false
    PubSub.thread
    while true
      if @@stopped
        PubSub.queue.clear
        break
      end

      if PubSub.queue.empty?
        PubSub.waiting.push.each {|thread| thread.wakeup }
        sleep
      end

      unless PubSub.queue.empty?
        publish_info = PubSub.queue.shift
        sender = publish_info[:sender]
        channel = publish_info[:channel]
        params = publish_info[:params]
        logger.info "Publish ObjectID:#{sender.__id__} of class #{sender.class.name} to #{channel} with #{params.to_s}"

        channel.sub_before "/" do |sub_channel|
          PubSub.events.fire sub_channel, *params
        end
        PubSub.events.fire "*", *params
      end
    end
  end

  def PubSub.stop
    @@stopped = true
    PubSub.thread.wakeup if PubSub.thread.status == "sleep"
  end

  protected

  def mutex
    @mutex ||= Mutex.new
  end

  def channel_handlers
    @channel_handlers ||= {}
  end

  def unsubscribe_safe(channel=nil, proc = nil)
      # unsubscribe from all object channels
      unless channel
        channel_handlers.each_key{ |channel_name| unsubscribe_safe channel_name}
        return
      end

      unless proc
        logger.info "Unsubscribe #{self.class.name} from #{channel}"
        channel_handlers[channel].each { |proc_handler| PubSub.events.remove channel, proc_handler }if channel_handlers.include? channel
        channel_handlers[channel].clear
        return
      end

      logger.info "Unsubscribe #{self.class.name} from #{channel} listener #{proc}"
      PubSub.events.remove channel, proc
      channel_handlers[channel].delete_if {|stored_event| stored_event == proc} if channel_handlers.include? channel
  end

  def PubSub.queue_size
    @@queue_size ||= 100
  end

  def PubSub.queue_size=(value)
    @@queue_size = value
  end

  def PubSub.waiting
    @@waiting ||= []
  end

  def PubSub.thread
    @@thread ||= Thread.current
  end

  def PubSub.queue
    @@queue ||= []
  end

  def PubSub.events
    @@events ||= RubyEvents::Events.new(self)
  end

end