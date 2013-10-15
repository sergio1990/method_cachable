require "method_cachable/version"
require "method_cachable/helper"

module MethodCachable

	include MethodCachable::Helper

  extend ActiveSupport::Concern

  included do
    def clear_cache
      flush_cache cache_list_key
      flush_cache "cache_list_key:#{self.class.name}"
      flush_cache "cache_list_key:#{self.class.superclass.name}"
    end

    def cache_list_key
      "cache_list_key:#{self.class.name}:#{self.id}"
    end
  end

  module ClassMethods

    def acts_as_cachable
      klass = self
      [:after_touch, :before_destroy, :after_save].each { |callback| klass.send(callback, :clear_cache) }
    end

    def cached_methods(*methods)
      name = self.name
      eval_string = ""
      methods.each do |method|
        method = method.to_s
        eval_string += "
          alias_method :old_#{method}, :#{method}

          def #{method}(*args)
            sig = createsig(args || self.id)
            with_env \"#{name}:#{method}:\#{self.id}:\#{sig}\", cache_list_key do
              old_#{method}(*args)
            end
          end
        "
      end
      class_eval(eval_string)
    end

  end

  def with_env(key, saving_key = nil, &block)
    if Rails.env.production?
    	unless saving_key.nil?
    		lst = Rails.cache.fetch saving_key do; [] end
    		lst << key unless lst.include?(saving_key)
    		Rails.cache.write saving_key, lst, expires_in: 24.hours
    	end
      Rails.cache.fetch key, expires_in: 2.hours, &block
    else
      yield
    end
  end

  def flush_cache(saving_key)
  	lst = Rails.cache.fetch saving_key do; [] end
  	lst.each {|key| flush_key(key) }
  end

  def flush_key(key)
    Rails.cache.delete key
  end
end
