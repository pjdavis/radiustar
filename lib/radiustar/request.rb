module Radiustar

  require 'socket'

  class Request

    def initialize(server, options = {})
      @host, @port = server.split(":")

      @dict = options[:dict].nil? ? Dictionary.default : options[:dict]
      @nas_ip = options[:nas_ip] || get_my_ip(@host)
      @nas_identifier = options[:nas_identifier] || @nas_ip
      @reply_timeout = options[:reply_timeout].nil? ? 60 : options[:reply_timeout].to_i
      @retries_number = options[:retries_number].nil? ? 1 : options[:retries_number].to_i

      @port = Socket.getservbyname("radius", "udp") unless @port
      @port = 1812 unless @port
      @port = @port.to_i	# just in case
      @socket = UDPSocket.open
      @socket.connect(@host, @port)
    end

    def authenticate(name, password, secret, user_attributes = {})
      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.gen_auth_authenticator
      @packet.code = 'Access-Request'
      @packet.set_attribute('User-Name', name)
      @packet.set_attribute('NAS-Identifier', @nas_identifier)
      @packet.set_attribute('NAS-IP-Address', @nas_ip)
      @packet.set_encoded_attribute('User-Password', password, secret)

      user_attributes.each_pair do |name, value|
        @packet.set_attribute(name, value)
      end

      retries = @retries_number
      begin
        send_packet
        @received_packet = recv_packet(@reply_timeout)
      rescue Exception => e
        retry if (retries -= 1) > 0
        raise
      end

      reply = { :code => @received_packet.code }
      reply.merge @received_packet.attributes
    end

    def authenticate_chap(name, password, secret, user_attributes = {})
      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.gen_auth_authenticator
      @packet.code = 'Access-Request'
      @packet.set_attribute('User-Name', name)
      @packet.set_attribute('NAS-Identifier', @nas_identifier)
      @packet.set_attribute('NAS-IP-Address', @nas_ip)
      @packet.set_chap_password('CHAP-Password', password)

      user_attributes.each_pair do |name, value|
        @packet.set_attribute(name, value)
      end

      retries = @retries_number
      begin
        send_packet
        @received_packet = recv_packet(@reply_timeout)
      rescue Exception => e
        retry if (retries -= 1) > 0
        raise
      end

      reply = { :code => @received_packet.code }
      reply.merge @received_packet.attributes
    end
    
    def accounting_request(status_type, name, secret, sessionid, user_attributes = {})

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code = 'Accounting-Request'

      @packet.set_attribute('User-Name', name)
      @packet.set_attribute('NAS-Identifier', @nas_identifier)
      @packet.set_attribute('NAS-IP-Address', @nas_ip)
      @packet.set_attribute('Acct-Status-Type', status_type)
      @packet.set_attribute('Acct-Session-Id', sessionid)
      @packet.set_attribute('Acct-Authentic', 'RADIUS')

      user_attributes.each_pair do |name, value|
        @packet.set_attribute(name, value)
      end

      @packet.gen_acct_authenticator(secret)

      retries = @retries_number
      begin
        send_packet
        @received_packet = recv_packet(@reply_timeout)
      rescue Exception => e
        retry if (retries -= 1) > 0
        raise
      end

      return true
    end

    def generic_request(code, secret, user_attributes = {})
      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code =  code
      @packet.set_attribute('NAS-Identifier', @nas_identifier)
      @packet.set_attribute('NAS-IP-Address', @nas_ip)

      user_attributes.each_pair do |name, value|
        @packet.set_attribute(name, value)
      end

      @packet.gen_acct_authenticator(secret)

      retries = @retries_number
      begin
        send_packet
        @received_packet = recv_packet(@reply_timeout)
      rescue Exception => e
        retry if (retries -= 1) > 0
        raise
      end

      return true
    end

    def coa_request(secret, user_attributes = {})
      generic_request('CoA-Request', secret, user_attributes)
    end

    def disconnect_request(secret, user_attributes = {})
      generic_request('Disconnect-Request', secret, user_attributes)
    end

    def accounting_start(name, secret, sessionid, options = {})
      accounting_request('Start', name, secret, sessionid, options)
    end

    def accounting_update(name, secret, sessionid, options = {})
      accounting_request('Interim-Update', name, secret, sessionid, options)
    end

    def accounting_stop(name, secret, sessionid, options = {})
      accounting_request('Stop', name, secret, sessionid, options)
    end

    def inspect
      to_s
    end

    private

    def send_packet
      data = @packet.pack
      @socket.send(data, 0)
    end

    def recv_packet(timeout)
      if select([@socket], nil, nil, timeout.to_i) == nil
        raise "Timed out waiting for response packet from server"
      end
      data = @socket.recvfrom(4096) # rfc2865 max packet length
      Packet.new(@dict, Process.pid & 0xff, data[0])
    end

    #looks up the source IP address with a route to the specified destination
    def get_my_ip(dest_address)
      orig_reverse_lookup_setting = Socket.do_not_reverse_lookup
      Socket.do_not_reverse_lookup = true

      UDPSocket.open do |sock|
        sock.connect dest_address, 1
        sock.addr.last
      end
    ensure
       Socket.do_not_reverse_lookup = orig_reverse_lookup_setting
    end

  end

end
