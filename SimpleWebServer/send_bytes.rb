require 'socket'

#------ Send Bytes/ Client application ------#
# send hexidecimal value to a server socket on
# local host @ a sepcified port. A demonstration
# Ruby socket program
# @author James Child
class SendBytes
	@hostname 
	@port

	def initialize(p)
		@hostname = 'localhost'
		@port = p
	end
	
	def send_bytes
		s = TCPSocket.new(@hostname, @port)
		s.puts [0x02].pack("C")
		
		puts s.gets
        s.close
	end
	
end
p = ARGV.first

client = SendBytes.new(p)
client.send_bytes
puts "Sent some bytes"
