# frozen_string_literal: true

require "rails_multistore/version"
require "rails_multistore/engine"

module RailsMultistore
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :async, :queue_name, :error_handler

    def initialize
      @async = true
      @queue_name = :default
      @error_handler = ->(error, store_name, operation) do
        Rails.logger.error("[RailsMultistore] Store: #{store_name}, Operation: #{operation}, Error: #{error.message}")
      end
    end
  end
end
