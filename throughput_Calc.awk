BEGIN {

  recvPacketSize=0;
  
  startTime=100;

}
 
{
    event = $1;
    time = $2;
    trace_level = $4;
    packet_size = $8;
  
    if(trace_level=="AGT" && event=="s")
     
    {
       if($2<startTime)      
          {startTime=$2;}
  
    }

    if(trace_level=="AGT" && event=="r")
    { 
       if(time>stopTime)   
          {stopTime=time;}
       recvPacketSize += packet_size;   
    } 
      
}

END {
  throughput_bytes = recvPacketSize/(stopTime-startTime);
  print("Throughput = ",throughput_bytes * 8 /1000,"Kbps");

}





