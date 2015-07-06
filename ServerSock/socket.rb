require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 3000

s = TCPSocket.open(hostname, port)

while line = s.gets   # Read lines from the socket
  puts line.chop      # And print with platform line terminator
  s.puts "hello server"
  sleep 1
end
s.close               # Close the socket when done
