require 'socket'
require 'thread'
require 'openssl'
require 'digest/sha1'
require 'base64'

# - - - - - - - - - - - - - AES Echo Server - - - - - - - - - - - - - - #
# @author: James Child
# @date: 28/07/2015
#
# Works exclusively with the AES Echo Client (aes_client.rb) designed to 
# echo an encrypted message to the echo client, in order to demonstrate 
# how OpenSSL AES-256-CBC encryption works.
#
# Sends secret key and initialization vector to client upon connection. 
# This isn't secure, but demonstrates the importance of key sharing. 
# Data echod back to the client it encoded before transmission. This 
# removes garabage bits added when trying to encrypt/ decrypt a string.
# Each stage is printed to the terminal for debugging and learning 
# purposes. 
# 
# Current Bugs: client crashes with "iv length too short" if message is
# too long. 
class Server 
	@@static_id = 0
	@connection_no 
	
	@port
	@server
	
	@aes_cipher
	@key
	
	def initialize(p)
		#setting up server connections
		puts "Starting server"		
		@port = p
		puts "connections on port #{@port} will be accepted"
		@server = TCPServer.open(@port)
		puts "Ctrl + C to shutdown server"
		
		#generate a secret key
		puts "creating secret key..."
		@aes_cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		@aes_cipher.encrypt
		@key = @aes_cipher.random_key
		@aes_cipher.key = @key
		puts "key: #{@key}"
		
		#start server		
		start_server
	end
	
	#Accepts client connections within a new thread (a concurrent server)
	def start_server	
		loop{
			Thread.new(@server.accept) do |client|
						
				#connection and request
				sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
				client_ip = remote_ip.to_s	
				@@static_id += 1
				@connection_no = @@static_id 				
				puts "\nConnection ##{@connection_no} client #{client_ip} accepted"	
				
				#send client secret key 
				client.puts @key						
							
				#receive data from client
				data = client.gets.chomp
				puts "received encoded: #{data}"
				
				decdata = Base64.decode64(data)
				puts "decoded message #{decdata}"
					
				#encrypts message with secret key and newly generated
				#initialization vector. 
				iv = @aes_cipher.random_iv	
				@aes_cipher.iv = iv
				puts "generated IV: #{iv}"
				encrypted = @aes_cipher.update(decdata)
				encrypted << @aes_cipher.final	
				puts "Encrypted Msg: #{encrypted}"				
					
				#send back IV and encrypted data
				enc_encrypted = Base64.encode64(encrypted)
				client.puts enc_encrypted
				client.puts iv				
				
				#close connections
				client.close		
				
			end
		}
	end
	
end

#what would me a main method in C/C++/Java
#Arguments, portnumber to accept client connections
p = ARGV.first
s = Server.new(p)

