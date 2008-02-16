Jim := Object clone do(
  port := 6667
  socket := Socket clone
  
  connect := method(nick, server, channelString,
    self nick := nick
    self channels := channelString split
    socket setHost(server) setPort(port) connect
    socket lnStreamWrite("USER #{nick} #{nick} #{nick} :Jim Bot" interpolate)
    socket lnStreamWrite("NICK #{nick}" interpolate)
    channels foreach(c, socket lnStreamWrite("JOIN #" .. c))
    socket streamReadNextChunk
    socket readBuffer empty
    
    parseIncomming
  )
  
  parseIncomming := method(
    while(socket isOpen, 
      socket streamReadNextChunk
      
      if (socket readBuffer size != 0,
        preline := socket readBuffer
        preline split("\r\n") foreach(l, 
          reply := parseLine(l)
          if(reply, send(reply))
        )
      )
      
      socket readBuffer empty
    )
  )
  
  parseLine := method(line,
    line println
    // ping PONG
    case(line,
      (beginsWithSeq("PING"),
        ("PONGED: " .. line) println
        return line replaceSeq("PING", "PONG")
      )
      (containsSeq("PRIVMSG #"),
        setSlot("sentNick", line betweenSeq(":", "!"))
        setSlot("sentChannel", line betweenSeq("#", " "))
        setSlot("text", line afterSeq(":") afterSeq(":"))
        case(text,
          (beginsWithSeq(Jim nick .. ":"), sendToChannel(sentChannel, text afterSeq(":")))
        )
      )
    )
    return false
  )
  
  sendToChannel := method(channel, line,
    send("PRIVMSG #" .. channel .. " :" .. line)
  )
  
  send := method(line,
   socket lnStreamWrite(line)
  )
  
  
)

////
// Addons

Socket lnStreamWrite := method(msg, self streamWrite(msg .. "\r\n"))

Object case := method(obj,
  m := call argAt(1)
  loop(
    if(obj doMessage(m argAt(0)),
      call sender doMessage(m argAt(1))
      break
    )
    m := m next ifNilEval(break)
    m := m next ifNilEval(break)
  )
)

Jim connect("Jimmmmmmm", "irc.freenode.net", "#fauna")