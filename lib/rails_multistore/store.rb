# frozen_string_literal: true

module RailsMultistore
  class Store
    attr_reader :name, :options, :adapter

    def initialize(name, options)
      @name = name
      @options = options
      load_adapter
    end

    private

    def load_adapter
      store_type = options[:type]
      raise ArgumentError, "Store type is required" unless store_type

      # Require the store engine gem
      require "rails_multistore_#{store_type}"

      # Instantiate the adapter
      adapter_class_name = "RailsMultistore#{store_type.to_s.camelize}::Adapter"
      adapter_class = adapter_class_name.constantize
      @adapter = adapter_class.new(options)
    rescue LoadError => e
      raise LoadError, "Could not load store engine for type '#{store_type}'. " \
                       "Make sure 'rails-multistore-#{store_type}' gem is installed. " \
                       "Original error: #{e.message}"
    rescue NameError => e
      raise NameError, "Could not find adapter class '#{adapter_class_name}'. " \
                       "Make sure the store engine implements the required adapter. " \
                       "Original error: #{e.message}"
    end
  end
end
