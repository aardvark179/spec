require File.dirname(__FILE__) + '/../../../spec_helper'
require 'net/http'
require File.dirname(__FILE__) + '/fixtures/http_server'

describe "Net::HTTP#do_finish" do
  before(:each) do
    NetHTTPSpecs.start_server
    @http = Net::HTTP.new("localhost", 3333)
  end
  
  after(:each) do
    NetHTTPSpecs.stop_server
  end

  it "is private" do
    Net::HTTP.private_instance_methods.should include("do_finish")
  end

  it "closes the tcp connection" do
    @http.start
    @http.send(:do_finish)
    @http.started?.should be_false
  end
  
  it "raises no error when self has not been started yet" do
    @http.send(:do_finish)
  end
end
