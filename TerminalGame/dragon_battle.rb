require 'thread'

# - - - - - - - - - - A Simple, incomplete Game - - - - - - - - - - #
# this is a terminal battle game. Not very good, as the players don't
# actually fight eachother. This is just to experiment with inheritance
# and threads. 
# 
# here, we have polymorphic objects, inheriting from the Creature class. 
# the child classes can use the parent class methods, but with overriden 
# functionality- if they so desire. 

$mutex = Mutex.new

class Creature
	@name
	@health
	@attack
	@defence
	
	def initialize(n, h,att,deff)
		@name = n
		@health = h
		@attack = att
		@defence = deff
	end
	
	def attack
		
	end
	
	def defend(attack)
	end
	
	def rest
	end
	
	def thread_start(process)
	
	Thread.new do
		process
	end
		#t1 = Thread.new{process}
		#t1.join
		#t1.join
	end #starts a process in a thread
end

class ElderDragon < Creature
	@fire_energy
	def initialize(n,h,att,deff,en)
		super(n,h,att,deff)
		@fire_energy = en
	end
	
	def attack
		if @fire_energy <= 0
			puts "#{@name} tries to attach, but is too tired"
			@health = @health - 5
		else		
			puts "#{@name} breaths fire"
			@fire_energy = @fire_energy -100
		end		
	end #override functionality	
	
	def defend(attack)
		if(@defence > attack)
			puts "#{@name} blocked your attack"
			@defence = @defence - (attack/3)
		else
			@health = @health - attack
			put "#{@name} took damage, health: #{@health}"			
		end
	end
	
	def rest
		i = 0
		while i<10
			$mutex.lock
			@health = @health + 10
			@fire_energy = @fire_energy + 35
			$mutex.unlock
			sleep(1)
			i = i + 1
		end	
		puts "#{@name} has rested, health #{@health}"	
	end	

end

class Hero < Creature
	@energy
	def initialize(n,h,att,deff,en)
		super(n,h,att,deff)
		@energy = en
	end
	
	def attack
		if @energy <= 0
			puts "You're too tired to attack, you need to rest"
			@health = @health - 5
		else		
			puts "You slash the enemy with your sword"
			@energy = @energy -5
		end	
	end
	
	def defend(attack)
		if(@defence > attack)
			puts "You blocked the attack, health: #{@health}"
			@defence = @defence - (attack*0.5)
		else
			@health = @health - attack
			put "You took damage, health: #{@health}"			
		end
	end

	def rest
		i = 0
		while i<10
			$mutex.lock
			@health = @health + 20
			@energy = @energy + 45
			$mutex.unlock
			sleep(1)
			i = i + 1
		end		
	end
	
end

you = Hero.new("Nuada", 100, 230,190,150)
enemy = ElderDragon.new("Alduin",300,460,375,470)

enemy.attack
sleep(1)
you.attack
sleep(1)

enemy.defend(100)
sleep(1)
you.defend(100)
sleep(1)

t1 = Thread.start{enemy.rest}
sleep(1)
you.attack
sleep(1)
you.attack
sleep(1)
you.attack
sleep(1)
t1.join # still makes the main thread wait
you.attack
puts "waiting... what do you want to do?"
temp = $stdin.gets.chomp.to_s

creature = Creature.new("",0,0,0)
creature = enemy #polymorphic instansiation
puts "Did this work? #{creature.inspect}" 


