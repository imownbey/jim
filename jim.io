Jim := Object clone do(
  port := 6667
  socket := Socket clone
  
  connect := method(nick, server, channels,
    channels = channels split
    socket setHost(server) setPort(port) connect
    socket lnStreamWrite("USER #{nick} #{nick} #{nick} :Jim Bot" interpolate)
    socket lnStreamWrite("NICK #{nick}" interpolate)
    channels foreach(c, socket lnStreamWrite("JOIN #" .. c))
    socket streamReadNextChunk
    socket readBuffer empty
    
    while(socket isOpen, readLine)
  )
  
  readLine := method(
    socket streamReadNextChunk
    if (socket readBuffer size != 0,
      parseLine(socket readBuffer)
      socket readBuffer empty
    )
  )
  
  parseLine := method(line,
    nil
  )
  
  
)

////
// Addons

Socket lnStreamWrite := method(msg, self streamWrite(msg .. "\r\n"))

Jim connect("Jimmmmmmm", "irc.freenode.net", "#fauna")