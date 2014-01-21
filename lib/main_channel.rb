class MainChannel < Channel
  def initialize(*params)
    super
    @subchannels = {}
  end

  def add_subchannel(channel, &block)
    @subchannels[channel] = block
  end

  def remove_subchannel(channel)
    channel.kill
    @subchannels[channel] = nil
  end

  def process
    result = self.read
    function = @subchannels[self.sender]
    begin
      instance_exec result, &function
    rescue => e
      puts "got an error #{e.inspect}"
    end
  end

  def run
    loop do
      process
    end
  end
end
