# Rails Multistore

Rails Multistore provides a unified interface for managing and interacting with multiple data stores in a Rails application. It allows you to push data to and query from multiple data stores simultaneously, with each store type implemented as a separate Rails engine.

## Features

- **Unified API**: A simple API for pushing and querying data across all configured stores.
- **Modular Architecture**: Each data store is a self-contained Rails engine, making the system easily extensible.
- **Multiple Instances**: Supports configuring and using multiple instances of the same store type.
- **Asynchronous Operations**: Pushes data to stores asynchronously using ActiveJob.
- **Rails-Native**: Integrates seamlessly with ActiveRecord and follows Rails conventions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-multistore'
```

And then execute:

```bash
$ bundle install
```

You will also need to add the gems for the specific store engines you want to use. For example, to use Elasticsearch, you would add:

```ruby
gem 'rails-multistore-elasticsearch'
```

## Usage

### 1. Configure Stores

In your ActiveRecord model, include the `RailsMultistore::Model` module and configure your desired stores using the `multistore` block:

```ruby
class Article < ActiveRecord::Base
  include RailsMultistore::Model

  multistore do
    store :primary_es, type: :elasticsearch, url: 'http://localhost:9200'
    store :secondary_es, type: :elasticsearch, url: 'http://localhost:9201'
    # Add other stores here, e.g., marklogic, neighbor, etc.
  end
end
```

### 2. Push Data

To push a model instance to all its configured stores, call the `multistore_push` method. This will enqueue a background job to perform the push asynchronously.

```ruby
article = Article.create(title: 'Hello World', content: 'This is my first article.')
article.multistore_push
```

You can also set up callbacks to automatically push data on create and update:

```ruby
class Article < ActiveRecord::Base
  include RailsMultistore::Model

  after_commit :multistore_push, on: [:create, :update]

  multistore do
    # ...
  end
end
```

### 3. Query Data

To query all configured stores for a model, use the `multistore_query` class method. This will return an aggregated array of results from all stores.

```ruby
results = Article.multistore_query('hello')
```

### 4. Configuration

Global configuration can be set in an initializer (`config/initializers/rails_multistore.rb`):

```ruby
RailsMultistore.configure do |config|
  config.async = true  # Enable/disable asynchronous pushes (default: true)
  config.queue_name = :multistore  # ActiveJob queue name (default: :default)
  config.error_handler = ->(error, store_name, operation) do
    Rails.logger.error("Store #{store_name} #{operation} failed: #{error.message}")
  end
end
```

## Creating a New Store Engine

To add support for a new data store, you can create a new store engine gem.

1.  **Generate the gem**: `rails plugin new rails-multistore-newstore --mountable`

2.  **Create the adapter**: In `lib/rails_multistore_newstore/adapter.rb`, create an `Adapter` class that implements the `initialize`, `push`, and `query` methods.

    ```ruby
    module RailsMultistoreNewstore
      class Adapter
        def initialize(options)
          # Initialize the client for the new store
        end

        def push(record)
          # Implement the logic to push a record to the store
        end

        def query(query_string)
          # Implement the logic to query the store
        end
      end
    end
    ```

3.  **Publish the gem**: Once your engine is complete, you can publish it to RubyGems.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your-username/rails-multistore. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
