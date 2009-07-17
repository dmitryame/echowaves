require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper'

describe <%= class_name %> do
  before(:each) do
    @<%= file_name %> = <%= class_name %>.new
  end

  it "should be valid" do
    @<%= file_name %>.should be_valid
  end
  
  describe "get and set" do
    it "should work with strings" do
      <%= class_name %>.set('abcde', "Something to set")
      <%= class_name %>.get('abcde').should == "Something to set"
    end
    it "should work with symbols" do
      <%= class_name %>.set('abcde', :a_symbol)
      <%= class_name %>.get('abcde').should == :a_symbol
    end
    it "should work with arrays" do
      array = [1, :b, "C"]
      <%= class_name %>.set('abcde', array)
      <%= class_name %>.get('abcde').should == array
    end
    it "should work with hashes" do
      hash = {:symbol => "A string", "stringy" => 23, 74 => :cheese}
      <%= class_name %>.set('abcde', hash)
      <%= class_name %>.get('abcde').should == hash
    end
    
    it "should :get in the same order they are :set" do
      <%= class_name %>.set('abcde', :first)
      <%= class_name %>.set('abcde', "second")
      
      <%= class_name %>.get('abcde').should == :first
      
      <%= class_name %>.set('abcde', 33.3333)
      
      <%= class_name %>.get('abcde').should == "second"
      <%= class_name %>.get('abcde').should == 33.3333
      <%= class_name %>.get('abcde').should be(nil)
    end
    
    it "should keep queues seperated" do
      <%= class_name %>.set('queue_1', :data_1)
      <%= class_name %>.set('queue_2', "DATA2")
      
      <%= class_name %>.get('queue_2').should == "DATA2"
      <%= class_name %>.get('queue_2').should be(nil)
      <%= class_name %>.get('queue_1').should == :data_1
      <%= class_name %>.get('queue_1').should be(nil)
    end
    
    it "should work with queue name as strings or symbols" do
      <%= class_name %>.set(:bah, "something about bah")
      <%= class_name %>.get("bah").should == "something about bah"
      
      <%= class_name %>.set("girah", {:craziness => "embodied"})
      <%= class_name %>.get(:girah).should == {:craziness => "embodied"}
    end
    
    it "should work with queue name as strings or integers" do
      <%= class_name %>.set(23, "something about bah")
      <%= class_name %>.get("23").should == "something about bah"
      
      <%= class_name %>.set("34", {:craziness => "embodied"})
      <%= class_name %>.get(34).should == {:craziness => "embodied"}
    end
  end
end