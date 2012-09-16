require 'securerandom'

module Literally
	class << self
		# This general approach is pulled from http://www.ruby-forum.com/topic/54096
		# with slight modification to allow for taking block arguments
		# and to avoid monkey-patching an existing method in Ruby
		def augmented_instance_exec(object, method, *args, &block)
	    mname = "__instance_exec_#{SecureRandom.uuid}"
	    class << object; self; end.class_eval do 
	    	define_method mname, &method
	    end
	    begin
	      ret = object.send(mname, *args, &block)
	    ensure
	      class << object; self; end.class_eval do 
	      	undef_method mname
	      end
	    end
	    ret
	  end

		def make(options = {})
			options = {:variables => {}, :methods => {}, :inherit => []}.merge(options)
			Class.new do 
				# inheritance hooks
				def method_missing(method, *args, &blk)
					@_literally_options[:inherit].each do |mimic|
						return mimic.send(method, *args, &blk) if mimic.respond_to?(method)
					end
					super(method, *args, &blk)
				end
				
				def respond_to?(method)
					return true if @_literally_options[:inherit].any? {|mimic| mimic.respond_to? method }
					super(method, *args, &blk)
				end
				
				# define variables
				attr_accessor *(options[:variables].keys)
			
				# define methods
				options[:methods].each_pair do |method, body|
					define_method method do |*args, &blk|
						if blk
							Literally.augmented_instance_exec(self, body, *args, &blk)
						else
							Literally.augmented_instance_exec(self, body, *args)
						end
					end
				end
				
				def initialize(options)
					@_literally_options = options
				end
			end.new(options).tap do |obj|
				# initialize
				options[:variables].each_pair do |var, init|
					obj.send(:"#{var}=", init)
				end
			end
		end
	end
	
	class Configuration
		def initialize
			@variables = {}
			@methods = {}
			@mimics = []
		end
	
		def inherit obj
			@mimics << obj
		end
		
		def mimic obj
			@mimics << obj
		end
		
		def method name, &body
			@methods[name] = body
		end
		
		def var name, value=nil
			@variables[name] = value
		end
		
		def make
			Literally.make(:inherit => @mimics, :variables => @variables, :methods => @methods)
		end
	end
end

def literally &block
	Literally::Configuration.new.tap do |conf|
		conf.instance_eval &block
	end.make
end
