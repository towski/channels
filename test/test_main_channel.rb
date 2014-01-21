require 'test/unit'
require_relative '../lib/channel'
require_relative '../lib/main_channel'
require_relative 'test_helper'
require 'ruby-debug'

class Main < MainChannel
  attr_accessor :test_done
end

class CosbyChannel < Channel
  SAYINGS = ["Bipping", "Bopping"]
  def run
    loop do
      write_out SAYINGS.sample
    end
  end
end

class MainChannelTest < Test::Unit::TestCase
  def test_listeners
    this_thread = Thread.current
    channel = Main.new
    channel.add_subchannel(CosbyChannel.new(channel)){ |result|
      if result == "Bipping"
        @channel_out.test_done = true
      else
        @channel_out.test_done = true
      end
      this_thread.wakeup
    }
    sleep
    assert channel.test_done
  end
end
