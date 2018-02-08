# FastMultiJson

[![Build Status](https://travis-ci.org/bf4/fast_multi_json.svg?branch=master)](https://travis-ci.org/bf4/fast_multi_json)

Based on the excellent [MultiJson gem](https://github.com/intridea/multi_json) but rather than having
an adapter, it just defines a `to_json` method which uses the fastest JSON encoder/decoder,
or whatever you decide.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_multi_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_multi_json

Or just [drop in the code](https://github.com/bf4/fast_jsonapi/blob/10a1dfd2411f7feee0196a43958445ca9af7f857/lib/fast_jsonapi/multi_to_json.rb).

## Usage

```ruby
FastMultiJson.to_json(object) # or dump
FastMultiJson.parse(json_string) # TBD, or load
```

## Development

1. Check out the repo.
2. Run `bin/setup` to install dependencies.
3. Run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bf4/fast_multi_json.

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastMultiJson project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bf4/fast_multi_json/blob/master/CODE_OF_CONDUCT.md).
