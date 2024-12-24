## AWK file for throughput ##
## awk -f throughputGraph.awk 20.tr > throughput.dat
## xgraph throughput.dat -titles -title "Throughput" -title_x "Time" -title_y "Throughput (kbps)"

BEGIN {
  recvNumPacket=0;
  sendSize=0;
  dropSize=0;
  startTime=0;
  simTime = 100;
  gotime = 1;
  throughput=0;
  timeInterval=1;
}
 
{
  event = $1;
  time = $2;
  trace_level = $4;
  packet_size = $8;
  packet_type = $7; 
  
  if ((event == "r") && (packet_type == "tcp") && (trace_level =="AGT"))
  {
  recvNumPacket++;
  }
  
  if (time>gotime)
  {
  	print gotime, (packet_size * recvNumPacket * 8.0 )/1000;
  	gotime+=timeInterval;
  	#recvNumPacket=0;
  }
  
}

END {
}





