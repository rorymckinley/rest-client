require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

require 'webmock/rspec'
include WebMock::API

describe RestClient do

  it "a simple request" do
    body = 'abc'
    stub_request(:get, "www.example.com").to_return(:body => body, :status => 200)
    response = RestClient.get "www.example.com"
    response.code.should == 200
    response.body.should == body
  end

  it "a simple request with gzipped content" do
    stub_request(:get, "www.example.com").with(:headers => { 'Accept-Encoding' => 'gzip, deflate' }).to_return(:body => "\037\213\b\b\006'\252H\000\003t\000\313T\317UH\257\312,HM\341\002\000G\242(\r\v\000\000\000", :status => 200,  :headers => { 'Content-Encoding' => 'gzip' } )
    response = RestClient.get "www.example.com"
    response.code.should == 200
    response.body.should == "i'm gziped\n"
  end

  it "a request with nested params" do
    body = 'abc'
    params = {:params => {:id => '50', :foo => 'bar'}}
    stub_request(:get, "http://www.example.com/").                                                                                                                                            
      with(:body => {"params"=>{"id"=>"50", "foo"=>"bar"}},
           :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'29', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(:status => 200, :body => "abc", :headers => {})

    response = RestClient.get_with_nested_params "www.example.com", params
    response.code.should == 200
    response.body.should == body
  end

  it "a 404" do
    body = "Ho hai ! I'm not here !"
    stub_request(:get, "www.example.com").to_return(:body => body, :status => 404)
    begin
      RestClient.get "www.example.com"
      raise
    rescue RestClient::ResourceNotFound => e
      e.http_code.should == 404
      e.response.code.should == 404
      e.response.body.should == body
      e.http_body.should == body
    end
  end


end
