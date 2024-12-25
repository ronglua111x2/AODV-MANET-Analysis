BEGIN {

  recvPacketSize=0;

  txsize=0;

  drpsize=0;

  stopTime=0;

  startTime=400;

  throughput=0;

}
 
{
    event = $1;
    time = $2;
    trace_level = $4;
    packet_size = $8;
 
  if(trace_level=="AGT" && event=="r")
    { 
       if(time>stopTime)   
          {stopTime=time;}
       recvPacketSize += packet_size;   
    } 
      
}

END {
print("Throughput = ",recvPacketSize/(stopTime-startTime),"Kbps");

}





