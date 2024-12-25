BEGIN {   
  recvPacket = 0;
  sendPacket = 0;
  routingpkts = 0;
}

{
  event = $1;
  trace_level = $4;

  if ( event == "s" && trace_level=="AGT")
     sendPacket++;

  if ( (event == "s" || event == "f") && trace_level=="RTR")
     routingPacket++;

  if ( event == "r" && trace_level=="AGT")
     recvPacket++;
}
END {
 printf("Packets Sent = %d packets\n", sendPacket);
 
 printf("Packets Received = %d packets\n", recvPacket);
 
 printf("Packet Delivery Ratio = %f \n", recvPacket/sendPacket*100);
 
 printf("Network Overhead = %d packets\n", routingPacket);
 
 exit 0;
}
