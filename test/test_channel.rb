require 'test/unit'
require_relative 'test_helper'
require_relative '../lib/channel'
require 'ruby-debug'

class ErnieChannel < Channel
end

class CosbyChannel < Channel
  SAYINGS = ["Bipping", "Bopping"]
  def run
    loop do
      self.write SAYINGS.sample
    end
  end
end

class MainChannel < Channel
  attr_accessor :test_done
  def run
  end
end

class ChannelTest < Test::Unit::TestCase
  def test_channel
    channel = Channel.new do |c|
      c.write('hey')
    end
    assert_equal 'hey', channel.read
  end

  def test_two_channels
    this_thread = Thread.current
    channel = Channel.new do |c|
      c.write('hey')
    end
    channel2 = Channel.new do |c|
      assert_equal 'hey', channel.read
      this_thread.wakeup
    end
    sleep
  end

  def test_async
    correct_output = []
    output = []
    this_thread = Thread.current
    c = Channel.new do |chan|
      5.times do 
        result = chan.read
        output << result
      end
      this_thread.wakeup
    end
    writer1 = Channel.new do 
      i = 0
      loop do
        c.write("joe %s" % i.to_s)
        correct_output << "joe #{i}"
        i += 1
        sleep rand(1..3)
      end
    end
    writer2 = Channel.new do 
      is = 0
      loop do
        c.write("jill %s" % is.to_s)
        correct_output << "jill #{is}"
        is += 1
        sleep rand(1..3)
      end
    end
    sleep
    writer1.kill
    writer2.kill
    assert correct_output.same_elements?(output)
  end

  def test_chinese_whispers
    n = 1000
    leftmost = right = Channel.new {}
    left = leftmost
    hash = {}
    n.times do |i|
      hash[i] = right
      right = Channel.new do |c|
        hash[i].write(1 + c.read)
      end
    end
    right.write(1)
    assert_equal 1001, leftmost.read
  end

  def test_needs_run_with_inheritance
    assert_raises(RuntimeError) {
      ernie = ErnieChannel.new
    }
  end

  def test_inheritance
    cosby = CosbyChannel.new
    assert CosbyChannel::SAYINGS.include?(cosby.read)
  end
end
