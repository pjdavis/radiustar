require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Radiustar::Value do    
  it "should get numeric value of NAS-Port-Type == Ethernet from dictionary.rfc2865" do
    dict = Radiustar::Dictionary.new
    dict.read(File.dirname(__FILE__) + '/../templates/dictionary.rfc2865')
    attribute = dict.find_attribute_by_name 'NAS-Port-Type'
    ethernet_value = attribute.find_values_by_name 'Ethernet'
    ethernet_value.id.should == 15
  end
end
