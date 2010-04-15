module Radiustar

  class ValuesCollection

    def initialize
      @collection = {}
      @revcollection = []
    end

    def add(name, id)
      @collection[name] ||= Value.new(name, id)
      @revcollection[id.to_i] ||= @collection[name]
    end

    def find_by_name(name)
      @collection[name]
    end

    def find_by_id(id)
      @revcollection[id]
    end

    def empty?
      @collection.empty?
    end

  end

  class Value
    attr_accessor :name

    def initialize(name, id)
      @name = name
      @id = id.to_i
    end

  end

end