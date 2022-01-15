# Implement the service
# This example just writes the info back to the client...
proc doService {sock msg} {
    # puts $sock "echosrv:$msg"
     puts "evaluating $msg"
     set eresult [eval $msg]
     # set eresult [eval "$msg"]
     puts "got $eresult"
     puts $sock "$eresult"
     flush $sock
}

# Handles the input from the client and  client shutdown
proc  svcHandler {sock} {
  set l [gets $sock]    ;# get the client packet
  if {[eof $sock]} {    ;# client gone or finished
     close $sock        ;# release the servers client channel
  } else {
    doService $sock $l
  }
}

# Accept-Connection handler for Server. 
# called When client makes a connection to the server
# Its passed the channel we're to communicate with the client on, 
# The address of the client and the port we're using
#
# Setup a handler for (incoming) communication on 
# the client channel - send connection Reply and log connection
proc accept {sock addr port} {
  
  # if {[badConnect $addr]} {
  #     close $sock
  #     return
  # }

  # Setup handler for future communication on client socket
  fileevent $sock readable [list svcHandler $sock]

  # Note we've accepted a connection (show how get peer info fm socket)
  puts "Accept from [fconfigure $sock -peername]"

  # Read client input in lines, disable blocking I/O
  fconfigure $sock -buffering line -blocking 0

  # log the connection
  puts "Accepted connection from $addr at [exec date]"
}


puts "Initializing socket on port $svcPort"

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.
socket -server accept $svcPort
vwait events    ;# handle events till variable events is set
