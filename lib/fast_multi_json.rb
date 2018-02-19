# frozen_string_literal: true

require 'fast_multi_json/version'
require 'logger'

# Usage:
#   class Movie
#     def to_json(payload)
#       ::FastMultiJson.to_json(payload)
#     end
#
#     def from_json(string)
#       ::FastMultiJson.from_json(string)
#     end
#   end
module FastMultiJson
  def self.logger(logger=nil)
    return @logger = logger if logger
    @logger ||= Logger.new(IO::NULL)
  end

  def self.to_json(object)
    _fast_to_json(object)
  rescue NameError
    define_to_json(::FastMultiJson)
    _fast_to_json(object)
  end

  def self.from_json(string)
    _fast_from_json(string)
  rescue NameError
    define_from_json(::FastMultiJson)
    _fast_from_json(string)
  end

  def self.define_to_json(receiver)
    cl = caller_locations[0]
    method_body = to_json_method
    logger.debug { "Defining #{receiver}._fast_to_json as #{method_body.inspect}" }
    receiver.instance_eval method_body, cl.absolute_path, cl.lineno
  end

  # Encoder-compatible with default MultiJSON adapters and defaults
  def self.to_json_method
    encode_method = String.new(%(def _fast_to_json(object)\n ))
    encode_method << Result.new {
      require 'oj'
      %(::Oj.dump(object, mode: :compat, time_format: :ruby, use_to_json: true, indent: 0))
    }.rescue {
      require 'yajl'
      %(::Yajl::Encoder.encode(object))
    }.rescue {
      require 'jrjackson' unless defined?(::JrJackson)
      if ::JrJackson::Json.method(:dump).arity == 1
        %(::JrJackson::Json.dump(object))
      else
        %(::JrJackson::Json.dump(object, ::FastMultiJson::EMPTY_OPTIONS.dup))
      end
    }.rescue {
      require 'json'
      %(::JSON.fast_generate(object, create_additions: false, quirks_mode: false))
    }.rescue {
      require 'gson'
      %(::Gson::Encoder.new(::FastMultiJson::EMPTY_OPTIONS.dup).encode(object))
    }.rescue {
      require 'active_support/json/encoding'
      %(::ActiveSupport::JSON.encode(object))
    }.rescue {
      warn "No JSON encoder found. Falling back to `object.to_json`"
      %(object.to_json(::JSON::FAST_STATE_PROTOTYPE.to_h))
    }.value!
    encode_method << "\nend"
  end

  def self.reset_to_json!
    undef :_fast_to_json if method_defined?(:_fast_to_json)
    logger.debug { "Undefining #{receiver}._fast_to_json" }
  end

  def self.define_from_json(receiver)
    cl = caller_locations[0]
    method_body = from_json_method
    logger.debug { "Defining #{receiver}._fast_from_json as #{method_body.inspect}" }
    receiver.instance_eval method_body, cl.absolute_path, cl.lineno
  end

  # Decoder-compatible with default MultiJSON adapters and defaults
  def self.from_json_method
    decode_method = String.new(%(def _fast_from_json(string)\n ))
    decode_method << Result.new {
      require 'oj'
      %(::Oj.load(string, mode: :strict, symbol_keys: false))
    }.rescue {
      require 'yajl'
      %(::Yajl::Parser.new(symbolize_keys: false).parse(string))
    }.rescue {
      require 'jrjackson' unless defined?(::JrJackson)
      %(::JrJackson::Json.load(string))
    }.rescue {
      require 'json'
      %(::JSON.parse(string, quirks_mode: false, symbolize_names: false))
    }.rescue {
      require 'gson'
      %(::Gson::Decoder.new(::FastMultiJson::EMPTY_OPTIONS.dup).decode(string))
    }.rescue {
      require 'active_support/json/decoding'
      %(::ActiveSupport::JSON.decode(string))
    }.rescue {
      fail "No JSON decoder found."
    }.value!
    decode_method << "\nend"
  end

  def self.reset_from_json!
    undef :_fast_from_json if method_defined?(:_fast_from_json)
    logger.debug { "Undefining #{receiver}._fast_from_json" }
  end

  # Result object pattern is from https://johnnunemaker.com/resilience-in-ruby/
  # e.g. https://github.com/github/github-ds/blob/fbda5389711edfb4c10b6c6bad19311dfcb1bac1/lib/github/result.rb
  class Result
    def initialize
      @value = yield
      @error = nil
    rescue LoadError => e
      @error = e
    end

    def ok?
      @error.nil?
    end

    def value!
      if ok?
        @value
      else
        raise @error
      end
    end

    def rescue
      return self if ok?
      Result.new { yield(@error) }
    end
  end
  private_constant :Result

  EMPTY_OPTIONS = {}.freeze
  private_constant :EMPTY_OPTIONS
end
