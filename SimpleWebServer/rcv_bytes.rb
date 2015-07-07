require 'socket'
require 'thread'

#------ Receive Bytes/ Simple Ruby Server ------#
# gets data from a client connection and
# prints it to the terminal window. My client
# application sends a hex value that prints
# a smilie face 
#
# This is now a webserver- but not a very good one!
# Doesn't conform to any webserver standards
# only responds to get requests
# very insecure! grants access to anything within
# its directory and below!
#
# It is quite efficient, dealing with requests within
# a dedicated thread. However, uses a few global 
# variables that aren't protected- they should be, 
# otherwise we could experience currency issues!
# 
# @author James Child
# 07/07/2015

class RcvBytes
	@hostname
	@port
	@server
	@request
	
	def initialize(p)
		@port = p
		@server = TCPServer.open(@port)
		get_bytes
	end
	
	def get_bytes
		loop{
			Thread.new(@server.accept) do |client|
				@request = client.gets		
				client.puts respond(@request)
				client.close
			end	
		}	
	end	
	
	def respond(res)
		file_array = nil
		str = res.to_s
		puts "Requested: #{str} @ #{Time.now}"	
		
		if str.match("GET")
		
			#regex to get file name
			req_file = str[/GET.*/].split('GET /')[1][/[^ ]+/]
			puts "Now: #{req_file}"		
			
			if File.exist?(req_file)
				puts "issued a get request"
				file = File.open(req_file)
				file_array = file.read().to_s
			else
				file_array = "Error: webpage doesn't exist"
			end	
			
		else
		
			puts "issued something else"
			file_array = "Unknown Request"
			
		end
		#file.close()
		return file_array
	end
	
end

#what would be the main
p = ARGV.first
server = RcvBytes.new(p)

