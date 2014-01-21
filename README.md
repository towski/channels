Implement Go style channels in ruby, asynchronous threads that can pass messages through a blocking channel.

In the following example, each separate channel is writing to a main channel whenever it receives a response, and the main channel pops the responses off as soon as it receives them. 

See Rob Pike's go talk: http://www.youtube.com/watch?v=f6kdp27TYZs

Simple example: 

```ruby
require 'channel'
# wait for input to the channel in a separate thread
channel = Channel.new{|c| loop { puts c.read } }
# send a message from the main thread
channel.write "I've... seen things you people wouldn't believe..."
sleep 2
channel.write "Attack ships on fire off the shoulder of Orion."
sleep 3
channel.write "I watched c-beams glitter in the dark near the Tannhauser Gate."
sleep 4
channel.write "All those... moments... will be lost in time, like... *cough*"
sleep 5
channel.write "tears... in... rain."
sleep 2
channel.write "Time... to die..."
sleep 2
```

More complicated example:

```ruby
require 'channel'
require 'net/http'

Channel.new do |main|
  Channel.new { main.write Net::HTTP.get('indietorrents.com', '/index.html') }
  Channel.new { main.write Net::HTTP.get('google.com', '/index.html') }
  Channel.new { main.write Net::HTTP.get('yelp.com', '/index.html') }
  loop do
    # outputs the response data in the order it is received
    puts main.read
  end
end

sleep
```
