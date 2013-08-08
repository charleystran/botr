require 'spec_helper'
require 'botr/http/multipart'

describe BOTR::Multipart do

	before :each do
		path = __dir__ + '/test.txt'
		@expected_response = "--753536\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\nContent-Length: 15\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: binary\r\n\r\nThis is a test.\r\n--753536--\r\n"
		@multipart = BOTR::Multipart.new(path, '753536')
	end

	describe "#read" do
		it "should return a string of content" do
			res = @multipart.read
			res.should be_kind_of String
			res.should eql @expected_response
  		end
	end

	describe "#size" do
		it "should return the number of bytes in content" do
			bytesize = @expected_response.bytesize
			@multipart.size.should eql bytesize
		end
	end

	describe "#close" do
		it "should close the IO stream" do
			@multipart.should_not be_closed
			@multipart.close
			@multipart.should be_closed
  		end
	end

end