module Radiustar

  class Dictionary

    DEFAULT_DICTIONARY_PATH = ::File.join(::File.dirname(__FILE__), '..', '..', 'templates', 'default.txt')

    def initialize(initial_path = nil)
      @attributes = AttributesCollection.new

      read initial_path if initial_path
    end

    def read(path)
      file = File.open(path) do |f|
        f.each_line do |line|
        	next if line =~ /^\#/	# discard comments
        	split_line = line.split(/\s+/)
        	next if split_line == []
          case split_line.first.upcase
          when "ATTRIBUTE"
            set_attr(split_line)
          when "VALUE"
            set_value(split_line)
          end
        end
      end

      def find_attribute_by_name(name)
        @attributes.find_by_name(name)
      end

      def find_attribute_by_id(id)
        @attributes.find_by_id(id)
      end

      def attribute_name_defined?(name)
        !@attributes.find_by_name(name).nil?
      end

      def attribute_id_defined?(id)
        !@attributes.find_by_id(id).nil?
      end

    end

    class << self

      def default
        new DEFAULT_DICTIONARY_PATH
      end

    end

    private

    def set_attr(line)
      @attributes.add(line[1], line[2], line[3])
    end

    def set_value(line)
      @attributes.find_by_name(line[1]).add_value(line[2], line[3])
    end

  end

end