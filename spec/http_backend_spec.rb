require 'spec_helper'
require 'botr/http/http_backend'

RSpec::Matchers.define :a_uri_path_of do |expected|
  match do |actual|
    (actual.should be_a_kind_of URI) && (actual.request_uri.should eql expected)
  end
  description do
    "a URI with path '#{expected}'"
  end
end

RSpec::Matchers.define :a_POST_request_with_path do |expected|
  match do |actual|
    (actual.should be_a_kind_of Net::HTTP::Post) && (actual.instance_variable_get('@path').should eql expected)
  end
  description do
    "a Net::HTTP::Post request with path '#{expected}'"
  end
end

describe BOTR::HTTPBackend do

	before :each do
		@http = mock("http")
		@resp = mock("response")

  		Net::HTTP.stub!(:start).and_yield(@http)
	end

	describe "#get" do

		before :each do
			@http.stub!(:request_get).and_return(@resp)
			@resp.stub!(:code).and_return(200)
			@resp.stub!(:body).and_return("")
		end

		it "should send HTTP GET request" do
			@http.should_receive(:request_get).with(an_instance_of(URI::HTTP))
			subject.get('http://www.example.com/')
		end

		it "should send HTTP GET request with params" do
			@http.should_receive(:request_get).with(a_uri_path_of("/?field1=value1&field2=value2"))
			subject.get('http://www.example.com/',
				{:field1 => "value1", :field2 => "value2"})
		end

		it "should return HTTP response" do
			res = subject.get('http://www.example.com')
			res.should be_an_instance_of BOTR::HTTPResponse
			res.status.should eql 200
			res.body.should be_empty
		end
	end

	describe "#post" do
		
		before :each do
			@http.stub!(:post_form).and_return(@resp)
			@http.stub!(:request).and_return(@resp)
			@resp.stub!(:code).and_return(200)
			@resp.stub!(:body).and_return("")
		end

		it "should send HTTP POST request" do
			@http.should_receive(:request).with(an_instance_of(Net::HTTP::Post))
			subject.post('http://www.example.com/')
		end

		it "should send HTTP POST request with params" do
			@http.should_receive(:request).with(a_POST_request_with_path("/?field1=value1&field2=value2"))
			subject.post('http://www.example.com/',
				{:field1 => "value1", :field2 => "value2"})
		end

		it "should send HTTP POST request with data" do
			@http.should_receive(:request).with(an_instance_of(Net::HTTP::Post))
			test_path = __dir__ + "/test.txt"
			subject.post('http://www.example.com/', {}, test_path)
		end

		it "should return HTTP response" do
			res = subject.post('http://www.example.com')
			res.should be_an_instance_of BOTR::HTTPResponse
			res.status.should eql 200
			res.body.should be_empty
		end

	end

end