require File.dirname(__FILE__) + '/../spec_helper'

describe AutoHtml do
  it 'should transform URL to Gist embed markup' do

    auto_html("http://gist.github.com/80392") { gist }.should == 
      '<script src="http://gist.github.com/80392.js"></script>'
    
  end
end