require_relative '../lib/literally'

describe Literally do 
	describe "make" do 
		before(:each) do 
			@o = Literally.make(:methods => {:go => proc { self.counter += 1; 3 }},
													:variables => {:counter => 0})
		end
		
		it "should respond to methods" do 
			@o.go.should == 3
		end
		
		it "should be able to update variables from within the methods" do
			@o.go
			@o.counter.should == 1
		end
		
		it "should call the supplied proc each time" do
			@o.go
			@o.go
			@o.counter.should == 2
		end
		
		it "should be able to take arguments to the methods" do
			n = Literally.make(:methods => {:inc => proc {|i| i + 1 }})
			n.inc(2).should == 3
		end
		
		it "should be able to inherit from another object via delegation" do
			n = Literally.make(:inherit => [Hash.new])
			n[:a] = 3
			n[:a].should == 3
		end

		it "should be able to take block arguments in the methods" do
			n = Literally.make(:methods => {:like_if => proc{ |b, &k| k.call if b }}, :variables => {})
			i = 0
			n.like_if true do
				i = 1
			end
			i.should == 1
			n.like_if false do
				i = 0
			end
			i.should == 1
		end
		
		it "should be able to make counters" do
			o = Literally.make(:methods => {:inc => proc { self.i += 1 }}, :variables => {:i => 0})
			o.inc
			o.i.should == 1
		end
	end
end
