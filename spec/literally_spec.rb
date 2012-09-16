describe :literally do
	it "should make objects with appropriate variables" do
		o = literally do
			var :i, 0
			var :e, 2
		end
		o.i.should == 0
		o.e.should == 2
	end
	
	it "should make objects with the appropriate methods" do 
		o = literally do
			var :i, 0
			method :inc do |amount = 1|
				self.i += (amount || 1)
			end
		end
		
		o.inc(2).should == 2
		o.inc.should == 3
		o.i.should == 3
	end
	
	it "should inherit and delegate within custom methods (like Hashes)" do
		h = Hash.new
		o = literally do
			inherit h
			method :is_this_town_big_enough_for_the_two_of_us? do
				h.size > 2
			end
		end
		
		o[:a] = 1
		o[:b] = 2
		o[:a].should == 1
		o[:b].should == 2
		o.size.should == 2
		o.is_this_town_big_enough_for_the_two_of_us?.should == false
		
		o[:c] = 3
		o.is_this_town_big_enough_for_the_two_of_us?.should == true
	end
end
