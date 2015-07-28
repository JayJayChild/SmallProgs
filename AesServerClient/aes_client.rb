require 'socket'
require 'thread'
require 'openssl'
require 'digest/sha1'
require 'base64'

# - - - - - - - - - - - - - AES Echo Client - - - - - - - - - - - - - - #
# @author: James Child
# @date: 28/07/2015
#
# Works exclusively with the AES Echo Server (aes_server.rb) designed to 
# send an unencrypted message to the echo server, receive it back 
# encrypted and decrypt the message, using the servers secret key. This 
# is to demonstrate how OpenSSL AES-256-CBC encryption works.
# 
# Data is taken from the command line and is encoded before transmission. 
# This removes garabage bits added when trying to encrypt and decrypt a 
# string. 
# 
# Current Bugs: client crashes with "iv length too short" if message is
# too long. 
class Aes_client
	@port
	@host
	@server
	
	def initialize(p,h)
		@hostname = h
		@port = p
		connect
	end
	
	def connect
		#establis connections
		s = TCPSocket.new(@hostname, @port)	
		
		#get key on connection
		key = s.gets
		puts "Key to decrypt: #{key}"
		
		#send data	
		data = $stdin.gets.chomp
		encdata = Base64.encode64(data)
		s.puts encdata		
		
		#receive message and IV
		message = s.gets.chomp
		dec_message = Base64.decode64(message)
		puts "Encrypted Message: #{dec_message}"		
		iv = s.gets
		puts "IV to decypt: #{iv}"	
		
		# now we create a sipher for decrypting
		cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		cipher.decrypt
		cipher.key = key
		cipher.iv = iv

		# and decrypt it
		decrypted = cipher.update(dec_message) 
		decrypted << cipher.final
		
		puts "decrypted: #{decrypted}\n"
		
        s.close
	end
end

#what would me a main method in C/C++/Java
# Arguments, portnumber and ip address of server
p = ARGV.first
h = ARGV.last
client = Aes_client.new(p,h)
