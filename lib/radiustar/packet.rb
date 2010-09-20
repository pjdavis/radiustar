module Radiustar

  require 'digest/md5'

  class Packet

    CODES = { 'Access-Request' => 1,        'Access-Accept' => 2,
              'Access-Reject' => 3,         'Accounting-Request' => 4,
              'Accounting-Response' => 5,   'Access-Challenge' => 11,
              'Status-Server' => 12,        'Status-Client' => 13 }


    HDRLEN = 1 + 1 + 2 + 16	# size of packet header
    P_HDR = "CCna16a*"	# pack template for header
    P_ATTR = "CCa*"		# pack template for attribute

    attr_accessor :code
    attr_reader :id, :attributes

    def initialize(dictionary, id, data = nil)
      @dict = dictionary
      @id = id
      unset_all_attributes
      if data
        @packed = data
        self.unpack
      end
      self
    end

    def increment_id
      @id = (@id + 1) & 0xff
    end

    def to_a
      @attributes.to_a
    end

    # Generate an authenticator. It will try to use /dev/urandom if
    # possible, or the system rand call if that's not available.
    def gen_authenticator
      if (File.exist?("/dev/urandom"))
        File.open("/dev/urandom") do |urandom|
          @authenticator = urandom.read(16)
        end
      else
        @authenticator = []
        8.times do
          @authenticator << rand(65536)
        end
        @authenticator = @authenticator.pack("n8")
      end
    end

    def set_attribute(name, value)
      @attributes[name] = value
    end

    def unset_attribute(name)
      @attributes[name] = nil
    end

    def attribute(name)
      @attributes[name]
    end

    def unset_all_attributes
      @attributes = Hash.new
    end

    def set_encoded_attribute(name, value, secret)
      @attributes[name] = encode(value, secret)
    end

    def pack

      attstr = ""
      @attributes.each_pair do |attribute, value|
        attribute = @dict.find_attribute_by_name(attribute)
        anum = attribute.id
        val = case attribute.type
        when "string"
          value
        when "integer"
          [attribute.has_values? ? attribute.find_values_by_id(value) : value].pack("N")
        when "ipaddr"
          [inet_aton(value)].pack("N")
        when "date"
          [value].pack("N")
        when "time"
          [value].pack("N")
        else
          next
        end
        attstr += [attribute.id, val.length + 2, val].pack(P_ATTR)
      end

      @packed = [CODES[@code], @id, attstr.length + HDRLEN, @authenticator, attstr].pack(P_HDR)
    end

    protected

    def unpack
      @code, @id, len, @authenticator, attribute_data = @packed.unpack(P_HDR)
      @code = CODES.index(@code)

      unset_all_attributes

      while attribute_data.length > 0 do
        length = attribute_data.unpack("xC").first.to_i
        attribute_type, attribute_value = attribute_data.unpack("Cxa#{length-2}")
        attribute_type = attribute_type.to_i

        attribute = @dict.find_attribute_by_id(attribute_type)
        attribute_value = case attribute.class
        when 'string'
          attribute_value
        when 'integer'
          attribute.has_values? ? attribute.find_values_by_id(attribute_value.unpack("N")[0]).name : attribute_value.unpack("N")[0]
        when 'ipaddr'
          inet_ntoa(attribute_value.unpack("N")[0])
        when 'time'
          attribute_value.unpack("N")[0]
        when 'date'
          attribute_value.unpack("N")[0]
        end

        set_attribute(attribute.name, attribute_value) if attribute
        attribute_data[0, length] = ""
      end
    end

    def inet_aton(hostname)
      if (hostname =~ /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/)
        return (($1.to_i & 0xff) << 24) + (($2.to_i & 0xff) << 16) + (($3.to_i & 0xff) << 8) + (($4.to_i & 0xff))
      end
      0
    end

    def inet_ntoa(iaddr)
      sprintf("%d.%d.%d.%d", (iaddr >> 24) & 0xff, (iaddr >> 16) & 0xff, (iaddr >> 8) & 0xff, (iaddr) & 0xff)
    end

    def xor_str(str1, str2)
      i = 0
      newstr = ""
      str1.each_byte do |c1|
        c2 = str2[i]
        newstr = newstr << (c1 ^ c2)
        i = i+1
      end
      newstr
    end

    def encode(value, secret)
      lastround = @authenticator
      encoded_value = ""
      # pad to 16n bytes
      value += "\000" * (15-(15 + value.length) % 16)
      0.step(value.length-1, 16) do |i|
        lastround = xor_str(value[i, 16], Digest::MD5.digest(secret + lastround) )
        encoded_value += lastround
      end
      encoded_value
    end

    def decode(value, secret)
      decoded_value = ""
      lastround = @authenticator
      0.step(value.length-1, 16) do |i|
	      decoded_value = xor_str(value[i, 16], Digest::MD5.digest(secret + lastround))
	      lastround = value[i, 16]
      end

      decoded_value.gsub!(/\000+/, "") if decoded_value
      decoded_value[value.length, -1] = "" unless (decoded_value.length <= value.length)
      return decoded_value
    end

  end
end