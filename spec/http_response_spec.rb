require 'spec_helper'
require 'botr/http/http_response'

describe BOTR::HTTPResponse do

	describe "OKResponse" do
		it "should return status 200" do
			resp = BOTR::OKResponse.new
    		resp.status.should eql 200
  		end
	end

	describe "BadRequestResponse" do
		it "should return status 400" do
			resp = BOTR::BadRequestResponse.new
    		resp.status.should eql 400
  		end
	end

	describe "UnauthorizedResponse" do
		it "should return status 401" do
			resp = BOTR::UnauthorizedResponse.new
    		resp.status.should eql 401
  		end
	end

	describe "ForbiddenResponse" do
		it "should return status 403" do
			resp = BOTR::ForbiddenResponse.new
    		resp.status.should eql 403
  		end
	end

	describe "NotFoundResponse" do
		it "should return status 404" do
			resp = BOTR::NotFoundResponse.new
    		resp.status.should eql 404
  		end
	end

	describe "NotAllowedResponse" do
		it "should return status 405" do
			resp = BOTR::NotAllowedResponse.new
    		resp.status.should eql 405
  		end
	end

end