module Radiustar

  class AttributesCollection < Array

    attr_accessor :vendor

    def initialize vendor=nil
      @collection = {}
      @revcollection = {}
      @vendor = vendor if vendor
    end

    def add(name, id, type)
      if vendor?
        @collection[name] ||= Attribute.new(name, id.to_i, type, @vendor)
      else
        @collection[name] ||= Attribute.new(name, id.to_i, type)
      end
      @revcollection[id.to_i] ||= @collection[name]
      self << @collection[name]
    end

    def find_by_name(name)
      @collection[name]
    end

    def find_by_id(id)
      @revcollection[id]
    end

    def vendor?
      !!@vendor
    end

  end

  class Attribute

    include Radiustar

    attr_reader :name, :id, :type, :vendor

    def initialize(name, id, type, vendor=nil)
      @values = ValuesCollection.new
      @name = name
      @id = id.to_i
      @type = type
      @vendor = vendor if vendor
    end

    def add_value(name, id)
      @values.add(name, id.to_i)
    end

    def find_values_by_name(name)
      @values.find_by_name(name)
    end

    def find_values_by_id(id)
      @values.find_by_id(id.to_i)
    end

    def has_values?
      !@values.empty?
    end

    def values
      @values
    end

    def vendor?
      !!@vendor
    end

  end

end
