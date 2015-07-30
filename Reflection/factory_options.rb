##### Reflection Interface implementing Dynamic Factory Options #######
# @author: James Child
# @date: 30/07/2015
#
# Uses reflection to inspect and manipulate objects at runtime. This is 
# to demonstrate how reflection could be used to create a terminal based
# manipulation tool for developers of a system. The terminal tool is 
# dynamically generated using the factory pattern, encapsulating each of
# its command options within seperate classes. 
#
# The simulated "program" to inspect consists of a few classes. On a 
# larger, more maintainable scale, this would should have access to the 
# application controller(s) and act as a seperate interface using, 
# reflection. 
#######################################################################

#######################################################################
#	(The simulated program) Classes to Inspect using Reflection		  #
#######################################################################

#Class describing a car
class Car
	#@car_name
	def initialize(n)
		@car_name = n
		@engine = "petrol"
		@wheels = 4
	end

	def set_engine(e)
		@engine = e
	end
	
	def get_wheels
		return @wheels
	end
end

#class describing a bike
class Bike
	def initialize(n)
		@bike_name=n
	end
end


#######################################################################

#######################################################################
# Abstract/ Interface API Module
# Throws abstract interface error if a class implementing an interface
# class does not provide implementation for the inherited methods. 
# Thanks to Mark Bates building interfaces and abstract classes article
# http://metabates.com/2011/02/07/building-interfaces-and-abstract-classes-in-ruby/
####################################################################### 
module AbstractInterface
	class InterfaceNotImplementedError < NoMethodError
	end
	
	def self.included(klass)
		klass.send(:include, AbstractInterface::Methods)
		klass.send(:extend, AbstractInterface::Methods)
	end
	
	module Methods
		def api_not_implemented(klass)
			caller.first.match(/in \'(.+)\'/)
			method_name = $1
			raise AbstractInterface::InterfaceNotImplementedError.new("#{klass.class.name} 
					needs to be implemented '#{method_name}' for interface #{self.name}!")
		end
	end
end

#######################################################################
# Opton interface for the option factory. This class is to allow for
# polymorphic instansiation 
#######################################################################
class OptionInterface 
	# includes AbstractInterface module to force implementation 
	# of implementation of inherited methods. 
	include AbstractInterface
	@@static_val = 0
	def initialize
		
	end
	
	def get_id
		OptionInterface.api_not_implemented(self)
	end
	
	def get_name
		OptionInterface.api_not_implemented(self)
	end
	
	def run_option(object_stack)
		OptionInterface.api_not_implemented(self)
	end
end

#######################################################################
# ShowAll option displays all Class objects in object stack at runtime. 
# implements the OptionInterface
#######################################################################
class ShowAll < OptionInterface
	def initialize(name)
		@@static_val += 1
		@id = @@static_val
		@option = name
	end

	def get_id
		return @id
	end
	
	def get_name
		return @option
	end
	
	def run_option(object_stack)
		object_stack.each{|x| print x.inspect; print x.object_id; print "\n"}
		puts ""
	end	
end

#######################################################################
# ShowAll option displays all Class objects in object stack at runtime. 
# implements the OptionInterface
#######################################################################
class InspectObject < OptionInterface
	def initialize(name)
		@@static_val += 1
		@id = @@static_val
		@option = name		
	end

	def get_id
		return @id
	end
	
	def get_name
		return @option
	end
	
	def run_option(object_stack)
		a = $stdin.gets.chomp
		name = a
		id = a.to_i
		begin
			object_stack.each do |x|
				array = x.instance_variables
				if x.object_id == id then p x end
					
				array.each do |e|
					if (x.instance_variable_get(e))==name
						p x.inspect
					elsif (x.instance_variable_get(e))==id
						p x.inspect
					end
				end
			end
		
		rescue => e
			puts "can't find object"
			puts e
		end
	end	
end

#######################################################################
# allows a user to manipulate an object using reflection. String values
# must be entered inside a ' ' block.
#######################################################################
class ChangeObject < OptionInterface
	def initialize(n)
		@@static_val += 1
		@id = @@static_val
		@name = n
	end
	
	def get_name 
		return @name
	end
	
	def get_id
		return @id
	end
	
	def run_option(object_stack)
		change = $stdin.gets.chomp
		id,attr,val = change.split(' ')
		if change.include?("'") then t,val = change.split("'") end
		id = id.to_i
			
		begin			
			object_stack.each do |i|
				if i.object_id == id then i.instance_variable_set(attr,val) end
			end
		rescue => e
			puts "Wrong params: #{e}"
		end
	end
end

#######################################################################
# gets all methods of an object. Only problem is that it also returns 
# the methods it inherits from the Object class.       
#######################################################################
class GetObjectMethods < OptionInterface
	def initialize(n)
		@name = n
		@@static_val += 1
		@id = @@static_val
	end
	
	def get_name
		return @name
	end
	
	def get_id
		return @id
	end
	
	def run_option(object_stack)
		obj = $stdin.gets.chomp.to_i
			object_stack.each do |i|
			if i.object_id == obj
				puts i.public_methods
				puts i.private_methods
				puts i.protected_methods
			end 
		end
	end
end

#######################################################################
# Allows a user to create an object at runtime using reflection
#######################################################################
class CreateObject < OptionInterface
	def initialize(n)
		@name = n
		@@static_val += 1
		@id = @@static_val
	end
	
	def get_name
		return @name
	end
	
	def get_id
		return @id
	end
	
	def run_option(object_stack)
		puts "does nothing at the moment"
	end
end


#######################################################################
# The OptionFactory is designed to manufacture options at start up, 
# based on the options created by polymorphic instansiation. All options
# implement the OptionInterface, therefore implement the necessary 
# methods used to get their ID, Name and Run options. This allows me to
# encapsulate each option within its own class. 
#######################################################################
class OptionFactory
	
	def initialize
		@options = Array.new
		@o1 = ShowAll.new("show all")
		@o2 = InspectObject.new("ins obj")
		@o3 = ChangeObject.new("chnge obj")
		@o4 = GetObjectMethods.new("ins obj methods")
		@o5 = CreateObject.new("new obj")
		
		@options.push(@o1)
		@options.push(@o2)
		@options.push(@o3)
		@options.push(@o4)
		@options.push(@o5)
		
		# ideally, this information should be encapsulated within its
		# own class, possibly a singleton object to pass its @object_stack
		# to the run_option method. 
		@object_stack = Array.new

		c1 = Car.new("Honda Civic")
		c2 = Car.new("Subaru Impreza")
		c3 = Car.new("Nissan Skyline")
		b1 = Bike.new("Yamaha R1")
		s1 = String.new("Hello String Class")
		
		ObjectSpace.each_object(Car){|x| @object_stack.push(x)}
		ObjectSpace.each_object(Bike){|x| @object_stack.push(x)}
		
	end
	
	#dynamically generates options and listens for input
	def get_option
		while 1
			puts "What do you want to do?"
			command = $stdin.gets.chomp			
			if command == "exit" then break; end
			
			@options.each do |i|
				if i.get_name == command
					choice = i.get_id
					i.run_option(@object_stack)
				end
			end
			
		end
	end
end

factory = OptionFactory.new
factory.get_option



