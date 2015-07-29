
#######################################################################
# Abstract/ Interface API Module
# Throws abstract interface error if a class implementing an interface
# class does not provide implementation for the inherited methods. 
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
	
	def initialize
	end
	
	def get_id
		OptionInterface.api_not_implemented(self)
	end
	
	def get_name
		OptionInterface.api_not_implemented(self)
	end
	
	def run_option
		OptionInterface.api_not_implemented(self)
	end
end

#######################################################################
# my first option (change this when I actually want to make options
# implements the OptionInterface
#######################################################################
class ShowAll < OptionInterface
	def initialize(id, name)
		@id = id
		@option = name
	end

	def get_id
		return @id
	end
	
	def get_name
		return @option
	end
	
	def run_option
	end
	
end

o1 = ShowAll.new(1, "show all")
o1.get_id
o1.get_name

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

class Bike
	def initialize(n)
		@bike_name=n
	end
end

c1 = Car.new("Honda Civic")
c2 = Car.new("Subaru Impreza")
c3 = Car.new("Nissan Skyline")
b1 = Bike.new("Yamaha R1")
s1 = String.new("Hello String Class")


#Reflection, inspects every Car object in object stack @ runtime
#ObjectSpace.each_object(Car){|x| p x}

#looking inside objects
#puts c1.class
#puts c1.instance_of?(Car)
#a = eval('c1')
#a.set_engine("Turbo i-Vtec 2l")
#puts a.inspect
#puts c1.inspect
#puts Car.public_instance_methods
#puts "id number #{c1.object_id}"

#puts all objects in an array for easy manipulation
object_stack = Array.new
ObjectSpace.each_object(Car){|x| object_stack.push(x)}
ObjectSpace.each_object(Bike){|x| object_stack.push(x)}

################################################################
# reflection program at runtime								   #
################################################################
loop{
	puts "What do you want to do?"
	
	#gets command
	command = $stdin.gets.chomp
	
	#command set
	case command
		################################################################
		# shows all objects in the object_stack array at runtime       #
		################################################################
		when "show all" 
			object_stack.each{|x| print x.inspect; print x.object_id; print "\n"}
			puts ""
		
		################################################################	
		# returns an object base on object id or the value of a        #
		# particular attribute										   #
		################################################################
		when "inspect obj"
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
		
		##################################################################
		# changes an objects selected attribute. @params obj_id attr val # 
		# String values must be surrounded by ' ' if they include spaces #
		##################################################################
		when "change obj"			
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
			
		################################################################
		# gets all methods of an object. Only problem is that it also  #
		# returns the methods it inherits from the Object class.       #
		################################################################
		when "get object methods"
			obj = $stdin.gets.chomp.to_i
			object_stack.each do |i|
				if i.object_id == obj
					puts i.public_methods
					puts i.private_methods
					puts i.protected_methods
				end 
			end
					
		################################################################
		# exit the program 											   #
		################################################################	
		when "exit" 
			break;
		
		################################################################
		# rescue from invalid command								   #
		################################################################
		else 
			puts "unknow command"
	end	
}

