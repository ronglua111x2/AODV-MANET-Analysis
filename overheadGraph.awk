## AWK file for Network Overhead ##
## awk -f overheadGraph.awk 20.tr > overhead.dat
## xgraph overhead.dat -titles -title "Overhead" -title_x "Time" -title_y "Overhead"
BEGIN{
    recvNumPacket = 0;# to calculate total number of data packets received
    rtNumPacket = 0;# to calculate total number of routing packets received
    timeInterval = 1;
    gotime = 1;
}

{
    event = $1;
    time = $2;
    trace_level = $4;
    packet_size = $8;
    packet_type = $7; 

    #Check if it is a data packet
    if (( event == "r") && ( packet_type == "cbr" || packet_type =="tcp" ) && ( trace_level=="AGT" )) rtNumPacket++;

    #Check if it is a routing packet
    if ((event == "s" || event == "f") && trace_level == "RTR" && (packet_type =="AODV" || packet_type =="message" || packet_type =="DSR" || packet_type =="OLSR")) recvNumPacket++;

    if (time>gotime)
    {
  	print gotime, recvNumPacket/rtNumPacket;
  	gotime+=timeInterval;
    }

}
END{
}
