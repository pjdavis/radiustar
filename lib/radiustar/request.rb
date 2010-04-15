module Radiustar

  require 'socket'

  class Request

    def initialize(server, my_ip, dict_file = nil)
      @dict = dict_file.nil? ? Dictionary.default : Dictionary.new(dict_file)
      @my_ip = my_ip
      @host, @port = server.split(":")
      @port = Socket.getservbyname("radius", "udp") unless @port
      @port = 1812 unless @port
      @port = @port.to_i	# just in case
      @socket = UDPSocket.open
      @socket.connect(@host, @port)
    end

    def authenticate(name, password, secret)
      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code = 'Access-Request'
      @packet.gen_authenticator
      @packet.set_attribute('User-Name', name)
      @packet.set_attribute('NAS-IP-Address', @my_ip)
      @packet.set_encoded_attribute('User-Password', password, secret)
      send_packet
      @recieved_packet = recv_packet
      return @recieved_packet.code == 'Access-Accept'
    end

    def get_attributes(name, password, secret)
      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code = 'Access-Request'
      @packet.gen_authenticator
      @packet.set_attribute('User-Name', name)
      @packet.set_attribute('NAS-IP-Address', @my_ip)
      @packet.set_encoded_attribute('User-Password', password, secret)
      send_packet
      @recieved_packet = recv_packet
      recieved_thing = [@recieved_packet.code]
      recieved_thing << @recieved_packet.attributes
    end

    def inspect
      to_s
    end

    private

    def send_packet
      data = @packet.pack
      @packet.increment_id
      @socket.send(data, 0)
    end

    def recv_packet
      if select([@socket], nil, nil, 60) == nil
	      raise "Timed out waiting for response packet from server"
      end
      data = @socket.recvfrom(64)
      Packet.new(@dict, Process.pid & 0xff, data[0])
    end


  end

end