require 'spec_helper'
require 'botr/api/authentication'

class DummyClient 

	def api_secret_key
		"uA96CFtJa138E2T5GhKfngml"
	end

end

describe BOTR::Authentication do

	before(:each) do
  		@dummy_client = DummyClient.new
  		@dummy_client.extend(BOTR::Authentication)
	end

	describe "#signature" do

		it "should generature signature" do
			params = {:text				=> "démo",
					  :api_format		=> "xml",
					  :api_key			=> "XOqEAfxj",
					  :api_nonce		=> "80684843",
					  :api_timestamp	=> "1237387851"}
			@dummy_client.signature(params).should eql "fbdee51a45980f9876834dc5ee1ec5e93f67cb89"
		end	
	end

end