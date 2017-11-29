# Minver

This gem provides a minimal HTTP server solution with two key features:

1. Graceful shutdown of the server
2. The caller can retrieve a value that is generated from the route handler

## Installation

Add this line to your application's Gemfile:

    gem 'minver'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minver

## Usage

This gem allows you to wait for user input via HTTP requests. For example:

```ruby
require 'minver'

# initialize server. default port is 18167, default bind is '::'
server = Minver::Base.new port: 3000

# Define your routes:

server.post "/name" do |request|
  name = request.params["name"]
  # pass this param to the caller
  pass name: name
  "Thanks, #{name}, your personal information was submitted."
end

server.post "/age" do |request|
  age = request.params["age"].to_i
  # pass this param to the caller
  if age < 5
    [400, {}, "Hey there, fella. You better ask your parents to use this app instead."]
  else
    pass age: age
    "Thank you, your age has been submitted!"
  end
end

# We're ready to go! Instantiate the hash where we store the info:

personal_info = {}

# And listen for requests!

loop do
  $stdout.puts "Provide your personal information over http://localhost:3000/name and /age"
  personal_info.merge!(server.run)
  break if personal_info.key?(:name) && personal_info.key?(:age)
end

# Now go to your terminal and make a request!
# e.g.:
# curl -XPOST -H"Content-Type: application/json" -d'{"name": "Danyel Bayraktar"}' localhost:3000/name
# or:
# curl -XPOST -d'age=3' localhost:3000/age


# Do something with this information!
puts "Hey #{personal_info[:name]}, #{personal_info[:age]} years is the best age to be starring my repo!"

# Don't forget to shut down the server
# (you can also call `stop` instead of `pass` from the route handler while still providing a value):
server.stop
```

## Contributing

1. Fork it ( https://github.com/muja/minver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
