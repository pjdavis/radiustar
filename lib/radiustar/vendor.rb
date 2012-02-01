module Radiustar

  class VendorCollection < Array

    def initialize
      @collection = {}
      @revcollection = []
    end

    def add(id, name)
      @collection[name] ||= Vendor.new(name, id)
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

  class Vendor

    include Radiustar

    attr_reader :name, :id

    def initialize(name, id)
      @name = name
      @id = id
      @attributes = AttributesCollection.new self
    end

    def add_attribute(name, id, type)
      @attributes.add(name, id, type)
    end

    def find_attribute_by_name(name)
      @attributes.find_by_name(name)
    end

    def find_attribute_by_id(id)
      @attributes.find_by_id(id.to_i)
    end

    def has_attributes?
      !@attributes.empty?
    end

    def attributes
      @attributes
    end

  end

end
