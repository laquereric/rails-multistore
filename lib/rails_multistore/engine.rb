# frozen_string_literal: true

require "rails_multistore/model"
require "rails_multistore/store"
require "rails_multistore/store_registry"

module RailsMultistore
  class Engine < ::Rails::Engine
    isolate_namespace RailsMultistore

    initializer "rails_multistore.initialize" do
      ActiveSupport.on_load(:active_record) do
        # Make the module available for inclusion
        # Models will include it explicitly
      end
    end
  end
end
