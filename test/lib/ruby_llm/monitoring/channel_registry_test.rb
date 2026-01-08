require "test_helper"

module RubyLLM::Monitoring
  class ChannelRegistryTest < ActiveSupport::TestCase
    setup do
      @registry = ChannelRegistry.new
      @test_channel_class = Class.new do
        def self.deliver(message, config)
          # Test implementation
        end
      end
    end

    test "registers a channel" do
      @registry.register(:test_channel, @test_channel_class)

      assert_equal @test_channel_class, @registry.fetch(:test_channel)
    end

    test "fetches registered channel by symbol" do
      @registry.register(:email, @test_channel_class)

      assert_equal @test_channel_class, @registry.fetch(:email)
    end

    test "fetches registered channel by string" do
      @registry.register(:email, @test_channel_class)

      assert_equal @test_channel_class, @registry.fetch("email")
    end

    test "registers channel with string name and converts to symbol" do
      @registry.register("email", @test_channel_class)

      assert_equal @test_channel_class, @registry.fetch(:email)
    end

    test "raises error when fetching unknown channel" do
      @registry.register(:email, @test_channel_class)

      error = assert_raises(ArgumentError) do
        @registry.fetch(:unknown)
      end

      assert_match(/Unknown channel: unknown/, error.message)
    end

    test "error message includes registered channels" do
      @registry.register(:email, @test_channel_class)
      @registry.register(:slack, @test_channel_class)

      error = assert_raises(ArgumentError) do
        @registry.fetch(:unknown)
      end

      assert_match(/Registered: email, slack/, error.message)
    end

    test "works with empty registry" do
      error = assert_raises(ArgumentError) do
        @registry.fetch(:email)
      end

      assert_match(/Unknown channel: email/, error.message)
      assert_match(/Registered: $/, error.message)
    end
  end
end
