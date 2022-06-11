# Chitragupta::Ruby

An easy to install Ruby gem to convert unstructured logs into informative structured logs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chitragupta', git: "git://github.com/browserstack/chitragupta-ruby.git"
```

## Usage

Add the following line wherever you want to use this package

```ruby
require "chitragupta"
```

### Using as Rack::CommonLogger

In case you have used Rack's CommonLogger to log application requests, you can simply replace Rack CommonLogger with Chitragupta's CommonLogger using following code:

```ruby
require "chitragupta"
require "logger"
server_logger = Logger.new('server.log')
use Chitragupta::CommonLoggerLog, server_logger
```

### Logging your Custom Logs

In case you have custom logger objects created, you can change the formatter(as below) to ensure the logs are structured.
```
logger = Logger.new('filename.log')
logger.formatter = Chitragupta::JsonLogFormatter.new
```

Passing values for `log.*` or `meta.*`
```
logger.info({ log: { id: 'some-unique-id', kind: 'UNIQUE_KIND' }})
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/browserstack/chitragupta-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
