require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe "Object with PubSub pattern" do
  before(:each) do
    PubSub.events.events_collection.clear
    @publisher  = Publisher.new
    @subscriber = Subscriber.new
  end

  it "should subscribe on channel" do
    @subscriber.subscribe "channel", @subscriber.method(:listener)
    PubSub.events.events_collection.size.should == 1
    PubSub.events.events_collection.should have_key "channel"
  end

  it "should unsubscribe specific listeners from channel" do
    @subscriber.subscribe "channel", @subscriber.method(:listener)
    @subscriber.unsubscribe "channel", @subscriber.method(:listener)
    PubSub.events.events_collection["channel"].should be_empty
  end

  it "should unsubscribe all listeners from channel" do
    @subscriber.subscribe "channel", @subscriber.method(:listener)
    @subscriber.subscribe "channel", @subscriber.method(:listener1)
    @subscriber.unsubscribe "channel"
    PubSub.events.events_collection["channel"].should be_empty
  end

  it "should unsubscribe from all channels" do
    @subscriber.subscribe "channel", @subscriber.method(:listener)
    @subscriber.subscribe "channel1", @subscriber.method(:listener1)
    @subscriber.unsubscribe
    PubSub.events.events_collection["channel"].should be_empty
    PubSub.events.events_collection["channel1"].should be_empty
  end

  it "should publish message to channel" do
    @subscriber.should_receive(:listener).with("Hello world")
    @subscriber.subscribe "channel", @subscriber.method(:listener)
    @subscriber.subscribe "channel", @subscriber.method(:listener_with_stop)
    @publisher.publish("channel", "Hello world")
    PubSub.run
  end

  it "should publish message to channel and subchannel" do
    @subscriber.should_receive(:listener).with("Hello world")
    @subscriber.subscribe "test/channel", @subscriber.method(:listener)

    @subscriber.should_receive(:listener1).with("Hello world")
    @subscriber.subscribe "test", @subscriber.method(:listener1)

    @subscriber.subscribe "test/channel", @subscriber.method(:listener_with_stop)
    @publisher.publish("test/channel", "Hello world")
    PubSub.run
  end

  it "should publish message to global channel" do
    @subscriber.should_receive(:listener).with("Hello world")
    @subscriber.subscribe "*", @subscriber.method(:listener)
    @subscriber.subscribe "*", @subscriber.method(:listener_with_stop)
    @publisher.publish("channel", "Hello world")
    PubSub.run
  end
end
