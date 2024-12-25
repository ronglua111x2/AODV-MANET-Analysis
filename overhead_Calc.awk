BEGIN{
recvPacket = 0;
routingPacket = 0;
}

{
    event = $1;
    time = $2;
    trace_level = $4;
    packet_type = $7; 
    packet_ID = $6; 

    if (( event == "r") && (packet_type =="tcp" ) && ( trace_level=="AGT" )) recvPacket++;

    if ((event == "s" || event == "f") && trace_level == "RTR" && (packet_type =="AODV" || packet_type =="message")) routingPacket++;
}

END{

    printf("Overhead Ratio = %.3f\n", routingPacket/recvPacket);

}