
Mac/802_11 set basicRate_ 11Mb              ;#Rate for Control FramesZ
Mac/802_11 set max_cache-entries 50

##Khởi tạo các tham số cài đặt mạng
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 20                         ;# max packet in ifq
##Khởi tạo các tham số tạo node
set val(nn)     30                         ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      7000                       ;# X dimension of topography
set val(y)      7000                       ;# Y dimension of topography
set val(stop)   40.0                       ;# time of simulation end
set val(source) 0                         ;# set source node
set val(dest)   24                          ;# set dest node
set val(speed)  20                          ;# set node speed
set ns [new Simulator]

#Setup topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)
#Open the NS trace file
set tracefile [open AODV.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open AODV.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile 800 600
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Bluetooth node parameter setup
#===================================

$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#Set up node
for {set i 0} {$i < $val(nn)} {incr i} {
    set n($i) [$ns node]
    $n($i) random-motion 0
    $ns initial_node_pos $n($i) 22
}
#Set up node position when start simulation
for {set i 0} {[expr $i < $val(nn)/10]} {incr i} {
    for {set j 0} {$j < 10} {incr j} {
        set id [expr $i*10 + $j]
        $n($id) set X_ [expr $j*100+120]
        $n($id) set Y_ [expr $i*100+120]
        $n($id) set Z_ 0.0
    }   
}
#set up run path for nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    if {$i%3 == 0} {
        $ns at 0.0 "$n($i) setdest [expr $i%7*1040+20] [expr $i%3*3000+20] $val(speed)"
    }
    if {$i%3 == 1} {
        $ns at 0.0 "$n($i) setdest [expr $i%6+20] [expr $i%3*3000+20] $val(speed)"
    }
    if {$i%3 == 2} {
        $ns at 0.0 "$n($i) setdest [expr $i%7*1040+20] [expr $i%3+10] $val(speed)"
    }
}

#### Setting The Labels For Nodes
$ns at 0.0 "$n($val(source)) label source"
$ns at 0.0 "$n($val(source)) color blue"
$n($val(source)) color "blue"
$ns at 0.0 "$n($val(dest)) label destination"
$ns at 0.0 "$n($val(dest)) color orange"
$n($val(dest)) color "orange"
   
#
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n($val(source)) $tcp
$ns attach-agent $n($val(dest)) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.1 "$ftp start"
$ns at $val(stop) "$ftp stop"

# In ns TCP connection will be green
$tcp set fid_ 1

# Establish a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n($val(source)) $udp
set null [new Agent/Null]
$ns attach-agent $n($val(dest)) $null
$ns connect $udp $null

# Udp nam in connection red
$udp set fid_ 2

set now 3.0
set time 3.0

$ns at [expr $now] "$ns trace-annotate \"Source broadcast route request packet to destination \""

$ns at [expr $now] "$ns trace-annotate \"Destination sends route reply to Source \""

#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam -r 0.75m AODV.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n($i) reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
