require "active_support/core_ext/hash/indifferent_access"

module FactoryBot
  # In Ruby <= 2.5 it is necessary to monkey patch
  # the key error class because it does not expose
  # receiver and key attributes.
  # See https://bugs.ruby-lang.org/issues/14313
  module KeyErrorExtension
    attr_accessor :receiver, :key

    def initialize(msg, key: nil, receiver: nil)
      @key = key
      @receiver = receiver
      super msg
    end
  end

  KeyError.prepend KeyErrorExtension

  class Registry
    include Enumerable

    attr_reader :name

    def initialize(name)
      @name  = name
      @items = ActiveSupport::HashWithIndifferentAccess.new
    end

    def clear
      @items.clear
    end

    def each(&block)
      @items.values.uniq.each(&block)
    end

    def find(name)
      if registered?(name)
        @items[name]
      else
        raise KeyError.new("#{@name} not registered: #{name}", receiver: @items, key: name)
      end
    end

    alias :[] :find

    def register(name, item)
      @items[name] = item
    end

    def registered?(name)
      @items.key?(name)
    end
  end
end
