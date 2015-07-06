# Pointless Server
# 
# Accepts requests on a secified port assigns the
# new connection its own thread.
#
# sends an incremented number to the client endlessly,
# along with the connected port number
#@author: James Child

require 'socket'              

class Server
	@port
	@server
	def initialize(p)
		@port = p
		@server = TCPServer.open(@port)
		connection
	end
	
	def connection
		loop{
			Thread.new(@server.accept) do |client|
			i = 0			  
			loop {                        
				#client.puts(Time.now.ctime) 
				client.puts "Reply #{i}, on port #{@port}"
				i = i + 1 
				sleep 1
			}
			end
		}
	end	
end

pn = ARGV.first
Server.new(pn)




