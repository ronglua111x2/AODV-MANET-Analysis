## AWK file for end to end delay. ## 
## awk -f delayGraph.awk 20.tr > delay.dat
## xgraph delay.dat -titles -title "N-N Delay" -title_x "Time" -title_y "Delay"

BEGIN{
	
    seqno = -1;
    count = 1;
    timeInterval=1;
    gotime = 1;
 
}


{
    event = $1;
    time = $2;
    trace_level = $4;
    packet_size = $8;
    packet_type = $7; 
    packet_ID = $6;

    if (time>gotime)
    {
        if(trace_level == "AGT" && event == "s" && seqno < packet_ID){

            seqno=packet_ID;

        }

        if(trace_level == "AGT" && event == "s") {

            start_time[packet_ID] = time;

        } 
        else if((packet_type == "tcp") && (event == "r")) {

            end_time[packet_ID] = time;

        } 
        else if((event == "D") && (packet_type == "tcp")) {

            end_time[packet_ID] = -1;

        }  
        for(i=0; i<= seqno; i++) {

            if(end_time[i] > 0){

            delay[i]= end_time[i] - start_time[i];

            count++;
            }
            else
            {
            delay[i]= -1;
            }
        }


        for(i=0; i <= seqno; i++) {

                if(delay[i] >0) {

                        n_to_n_delay = n_to_n_delay + delay[i];

                }
        }

        n_to_n_delay = n_to_n_delay/count;
        print gotime, n_to_n_delay * 1000;
        gotime += timeInterval;

    }

}


END { 


}

