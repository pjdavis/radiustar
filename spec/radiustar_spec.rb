require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Radiustar::Packet do    
  it "gen_authenticator generates a random string without /dev/urandom" do
    File.stub(:exist?).and_return(false)
    packet = Radiustar::Packet.new(nil, nil)
    packet.gen_authenticator.class.should == String
  end

  if File.exist?("/dev/urandom") # don't fail if specs are running on a platform without /dev/urandom
    it "gen_authenticator generates a random string with /dev/urandom" do
      packet = Radiustar::Packet.new(nil, nil)
      packet.gen_authenticator.class.should == String
    end
  end
end