module Radiustar

  class AttributesCollection < Array

    def initialize
      @collection = {}
      @revcollection = []
    end

    def add(name, id, type)
      @collection[name] ||= Attribute.new(name, id.to_i, type)
      @revcollection[id.to_i] ||= @collection[name]
      self << @collection[name]
    end

    def find_by_name(name)
      @collection[name]
    end

    def find_by_id(id)
      @revcollection[id.to_i]
    end

  end

  class Attribute

    include Radiustar

    attr_reader :name, :id, :type

    def initialize(name, id, type)
      @values = ValuesCollection.new
      @name = name
      @id = id.to_i
      @type = type
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

  end

end