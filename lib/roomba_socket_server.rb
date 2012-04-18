#!/usr/bin/env ruby
require 'rubygems'
require 'serialport'
require 'socket'
require 'optparse'
include Math
require_relative 'roomba.rb'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do |opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: ./roomba_socket_server.rb [options] roomba-socket-location"

  # Define the options, and what they do
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  options[:port] = 3001
  opts.on( '-p', '--port', 'Specify the TCP Socket Server Port' ) do |port|
    options[:port] = port
  end

  options[:latency] = 0
  opts.on( '-l', '--latency', 'Specify the Roomba latency' ) do |latency|
    options[:latency] = latency
  end

  options[:baud] = 115200
  opts.on( '-b', '--baud', 'Specify the Roomba baud' ) do |baud|
    options[:baud] = baud
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files.
optparse.parse!

ARGV.each do |f|
  puts f
  puts options[:latency]
  puts options[:baud]
  puts $roomba = Roomba.new(f.to_s,options[:latency],options[:baud])#need to add support for other initializer arguments
end
server = TCPServer.open(options[:port])   # Socket to listen on
idletime = Time.now
Thread.abort_on_exception = true
loop do
  puts "Roomba Socket Server Running! (30 second timeout)"
  Thread.start { sleep 30; raise "killed by timeout" if (idletime - Time.now).abs > 20;}
  Thread.start(server.accept) do |client|
    command_array = client.gets("$ROOMBA$").gsub("$ROOMBA$","").split("$RoR$")
    puts command_array.inspect
    command = command_array.shift
    if !command.nil?
      idletime = Time.now
      client.puts($roomba.send(command,*command_array.collect! {|v| v.to_i})) # Send the time to the client
      client.puts "Closing the connection. Bye!"
      raise "killed by client" if command == "kill"
    end
    client.close# Disconnect from the client
  end
end