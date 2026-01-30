# frozen_string_literal: true

module RailsMultistore
  class StoreRegistry
    attr_reader :stores

    def initialize
      @stores = []
    end

    # Register a new store
    # @param name [Symbol] The name of the store
    # @param options [Hash] Configuration options for the store
    def store(name, options)
      @stores << Store.new(name, options)
    end

    # Push a record to all configured stores
    # @param record [ActiveRecord::Base] The record to push
    def push(record)
      stores.each do |store|
        begin
          store.adapter.push(record)
        rescue StandardError => e
          handle_error(e, store.name, :push)
        end
      end
    end

    # Query all configured stores
    # @param query_string [String] The query string
    # @return [Array] Aggregated results from all stores
    def query(query_string)
      results = []
      stores.each do |store|
        begin
          store_results = store.adapter.query(query_string)
          results.concat(Array(store_results))
        rescue StandardError => e
          handle_error(e, store.name, :query)
        end
      end
      results
    end

    private

    def handle_error(error, store_name, operation)
      if RailsMultistore.configuration&.error_handler
        RailsMultistore.configuration.error_handler.call(error, store_name, operation)
      else
        Rails.logger.error("[RailsMultistore] Error in #{operation} for #{store_name}: #{error.message}")
      end
    end
  end
end
