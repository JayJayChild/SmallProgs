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
# 
# Improved the security, so now, the server will only
# return pages from within the "pages" directory.
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
	@logger
	$mutex = Mutex.new
	
	def initialize(p)
		@port = p
		@logger = ServerLog.new()
		@server = TCPServer.open(@port)
		get_bytes
	end
	
	def get_bytes
		loop{
			Thread.new(@server.accept) do |client|
				#connection and request
				sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
				client_ip = remote_ip.to_s	
							
				#mutex - protect @request
				$mutex.lock				
					@request = client.gets		
					puts "request: #{@request}"
				$mutex.unlock
				
					puts "@ #{Time.now}"
					
					#log request
				$mutex.lock
					req = @request.slice(0..(@request.index('/1.1')))
					@logger.log(req,Time.now,client_ip)
					
					#respond - function blocks access to pages/files
					#within the servers working directory. 
					if @request.match("/pages/*")
						client.puts respond(@request)
					else
						client.puts "Access denied"
						@logger.log("Access Denied",Time.now,client_ip)
					end
					
				$mutex.unlock
				client.close
			end	
		}	
		#mutex.lock
	end	
	
	def respond(res)
		file_array = nil
		str = res.to_s
		
		if str.match("GET")		
			#regex to get file name
			req_file = str[/GET.*/].split('GET /')[1][/[^ ]+/]		
			
			#carries out exist check
			if File.exist?("#{req_file}")
				file = File.open("#{req_file}")
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

class ServerLog
	def initialize()
	end
	
	def log(req,time,addr)		
		
		if !File.exist?('logs/')
			puts "it doesn't, so I'll create it"
			logger_files = Dir.mkdir 'logs/'
		end

		logs = File.open('logs/requests.csv','a+')
		logs.write("\n#{req}, @#{time}, IP: #{addr}")
		logs.close()	
	end
	
end

#what would be the main
p = ARGV.first
server = RcvBytes.new(p)

