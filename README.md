# MethodCachable

Provides setting specific methods list that must be cached and clearing cache on CRUD operations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'method_cachable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install method_cachable

## Usage

### Basic configuration

```ruby
class Post < ActiveRecord::Base
	include MethodCachable

	belongs_to :menu_item

	# Add this line for callbacks working
	acts_as_cachable

	# You want to cache association calling...
	def menu_item_title
		self.menu_item.title
	end

	# ...or maybe some evaluations
	def some_evaluations
		# There must be your code
	end

	# Specify list of cachable methods.
	cached_methods :menu_item_title, :some_evaluations
end
```

**_PLEASE NOTE_**: after save/touch/destroy cache will expire automatically.

### Cache storage

For storing cached methods gem using *Rails.cache*. Therefore you must set in rails application config file *cache_store* option. I highly recommend using the couple of *memcached*+*dalli* because they work very quickly. For this, you must add gem dalli to your Gemfile:

```ruby
gem 'dalli'
```

And then configurate it in *production.rb*:

```ruby
YourApp::Application.configure do
	config.cache_store = :dalli_store, { namespace: :world_try, expires_in: 2.hours, compress: true }
	# Rest of configuration
end
```

**_PLEASE NOTE_**: you don't need to configurate cache_store in development mode because for convenient development caching is off and method is called directly.

## Future developing

Now you may to cache only instance methods but caching class methods gem doesn't allow. In future, I will implement this functionality.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
