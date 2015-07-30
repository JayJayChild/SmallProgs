#################### Lambda Integer and Binary Calculator ######################
# This program demonstrates the power and usefulness of basic lambda expressions
# to create calculator functions. The code interprits mathmatical commands from 
# the input terminal and executes the relevent lambda expression. Clever stuff!
# 
# @author: James Child
# @date: 30/07/2015
################################################################################
x = 0
y = 0
ans = 0

#lambdas
add = lambda { x+y }
sub = lambda { x-y }
mult = lambda { x*y }
AND = lambda { x&y }
OR = lambda { x|y }
div = lambda { x/y }
rem = lambda { x%y }
power = lambda { x**y }
XOR = lambda { x^y }
help = "x + y, x - y, x * y, x and y, x or y, \nx / y, x rem y, x power y, x xor y"

#these give odd number list for hash errors when implemented?
sleft = lambda = {  }
sright = lambda = {  }
comp = lambda = {  }

#calculator
puts "Integer and Binary Calculator, 'help' for command list, close' to quit."
loop{
	ans = $stdin.gets.chomp
	break if ans=="close"
	puts help if ans=="help"

	
	if ans.include?("0b")
		ex,func,why = ans.split(' ')
		bin,x = ex.split('0b')
		bin,y = why.split('0b')
		begin
			x = x.to_i(2)
			y = y.to_i(2)
		rescue => e
			puts "Binary error: #{e}"
		end
	else	
		ex,func,why = ans.split(' ')
		x = ex.to_i				
		y = why.to_i
	end
	
	#calculator function
	begin 
		case func
			when "+"
				puts add.call
				
			when "-"
				puts sub.call
			
			when "*"
				puts mult.call
			
			when "/"
				puts div.call
			
			when "and" 
				puts "#{AND.call} binary: #{sprintf("%#b",AND.call)}"
			
			when "or" 
				puts "#{OR.call} binary: #{sprintf("%#b",OR.call)}"
				
			when "rem"
				puts rem.call
				
			when "power" 
				puts power.call
				
			when "xor" 
				puts "#{XOR.call} binary: #{sprintf("%#b",XOR.call)}"
				
			when "left"
				puts "#{sleft.call} binary: #{sprintf("%#b",sleft.call)}"
			
			when "right"
				puts "#{sright.call} binary: #{sprintf("%#b",sright.call)}"
			
			when "comp"
				puts "#{comp.call} binary: #{sprintf("%#b",comp.call)}"
				
			else 
				puts "not recognised"
		end
	rescue => e
		puts "Maths error: #{e}"
	end
	x,y=0			
}
