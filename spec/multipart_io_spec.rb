require 'spec_helper'
require 'botr/common/multipart_io'

describe BOTR::MultipartIO do

	before :each do
		@text = %W(#{"This is an IO-like object.\n"}
			#{"This is another one.\n"}
			#{"And this is the end."})

		@a = StringIO.new(@text[0])
		@b = StringIO.new(@text[1])
		@c = StringIO.new(@text[2])

		@multipartIO = BOTR::MultipartIO.new(@a, @b, @c)
	end

	describe "#read" do
		it "should concatenate IO streams" do
			res = @multipartIO.read
			res.should eql @text.join("")
  		end
	end

	describe "#size" do
		it "should return the number of bytes" do
			len = @text.map { |e| e.length }.reduce(:+)
			@multipartIO.size.should eql len
		end
	end

	describe "#rewind" do
		it "should position io to the beginning" do
			@multipartIO.read
			@multipartIO.read.should eql ""
			@multipartIO.rewind
			@multipartIO.read.should eql @text.join("")
		end
	end

	describe "#close" do
		it "should close all IO streams" do
			@multipartIO.close
			@a.closed?.should be_true
			@b.closed?.should be_true
			@c.closed?.should be_true
  		end
	end

end