# The faithful friend- I can only ever have one dog;
# he's irriplacable!

class Dog
	@human_years = 0
	@dog_years = 7
	@@instance = nil
	
	private_class_method :new
	
	def initialize()
	
	end
	
	def self.get_instance
		return @@instance ||= new
	end
	
	def set_age(age)
		@dog_years = age
	end
	
	def how_old_in_dog_years
		return @human_years*@dog_years
	end
	
	def get_age
		return @human_years
	end		
	
end

puts @bucky = Dog.get_instance   
puts @the_replacement_dog = Dog.get_instance




