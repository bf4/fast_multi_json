require 'bundler/inline'

RSpec.describe FastMultiJson do
  context "encoding" do
    it "uses JSON" do
      method_body, actual = bundle_with_unbundled_env do
        `bin/json-encode {fast: :encoding}`
      end.split("\n").compact

      expect(method_body).to start_with("::JSON.fast_generate")
      expect(actual).to eq(%({"fast":"encoding"}))
    end

    it "uses Oj" do
      method_body, actual = bundle_with_unbundled_env do
        `bin/oj-encode {fast: :encoding}`
      end.split("\n").compact

      expect(method_body).to start_with("::Oj")
      expect(actual).to eq(%({"fast":"encoding"}))
    end

    it "uses Yajl" do
      method_body, actual = bundle_with_unbundled_env do
        `bin/yajl-encode {fast: :encoding}`
      end.split("\n").compact

      expect(method_body).to start_with("::Yajl")
      expect(actual).to eq(%({"fast":"encoding"}))
    end

    it "never uses ActiveSupport while the JSON gem is installed" do
      method_body, actual = bundle_with_unbundled_env do
        `bin/active_support-encode {fast: :encoding}`
      end.split("\n").compact

      expect(method_body).to start_with("::JSON.fast_generate")
      expect(actual).to eq(%({"fast":"encoding"}))
    end
  end

  context "decoding"

  def bundle_with_unbundled_env(&block)
    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env(&block)
    else
      Bundler.with_clean_env(&block)
    end
  end
end
