BEGIN{
recvPacket = 0;# to calculate total number of data packets received
routingPacket = 0;# to calculate total number of routing packets received
}

{
    event = $1;
    time = $2;
    trace_level = $4;
    packet_type = $7; 
    packet_ID = $6; 
    
    #Check if it is a data packet
    if (( event == "r") && (packet_type =="tcp" ) && ( trace_level=="AGT" )) recvPacket++;

    #Check if it is a routing packet
    if ((event == "s" || event == "f") && trace_level == "RTR" && (packet_type =="AODV" || packet_type =="message")) routingPacket++;
}

END{

    printf("Overhead Ratio = %.3f\n", routingPacket/recvPacket);

}