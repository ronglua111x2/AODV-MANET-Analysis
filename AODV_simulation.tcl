Mac/802_11 set basicRate_ 11Mb             ;
##Khởi tạo các tham số tạo node
set val(chan)   Channel/WirelessChannel    ;# kiểu kênh truyền
set val(prop)   Propagation/TwoRayGround   ;# kiểu truyền dữ liệu
set val(netif)  Phy/WirelessPhy            ;# giao diện mạng
set val(mac)    Mac/802_11                 ;# MAC 
set val(ifq)    Queue/DropTail/PriQueue    ;# giao diện hàng đợi
set val(ll)     LL                         ;# kiểu lớp link
set val(ant)    Antenna/OmniAntenna        ;# kiểu anten
set val(ifqlen) 20                         ;# số gói tối đa trong hàng đợi
set val(rp)     AODV                       ;# giao thức định tuyến
set chan [new $val(chan)]                  ;# kênh truyển
##Khởi tạo các tham số khác
#Số nút (chia hết cho 10)
set val(nn)     30;      
#Vùng mô phỏng                                      
set val(x)      7000;                       
set val(y)      7000;
#Thời gian mô phỏng                       
set val(stop)   40.0;
#Nút nguồn, nút đích, tốc độ                     
set val(source) 0;                         
set val(dest)   24;                          
set val(speed)  20;                          

set ns [new Simulator]

#Tạo vùng mô phỏng
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#Gán biến và tạo file Trace và NAM
set tracefile [open AODV.tr w]
$ns trace-all $tracefile

set namfile [open AODV.nam w]
$ns namtrace-all $namfile
#Khởi tạo vùng hiển thị khi mở NAM
$ns namtrace-all-wireless $namfile 800 600

## Cài đặt tham số chung cho các nút
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

#Khởi tạo các nút
create-god $val(nn)
for {set i 0} {$i < $val(nn)} {incr i} {
    set n($i) [$ns node]
    $n($i) random-motion 0
    $ns initial_node_pos $n($i) 22
}
#Sắp xếp các nút thành các hàng ở thời điểm ban đầu
for {set i 0} {[expr $i < $val(nn)/10]} {incr i} {
    for {set j 0} {$j < 10} {incr j} {
        set id [expr $i*10 + $j]
        $n($id) set X_ [expr $j*100+120]
        $n($id) set Y_ [expr $i*100+120]
        $n($id) set Z_ 0.0
    }   
}
#Gắn đích đến và tốc độ cho các nút (ngoại trừ nút số 0 sẽ đứng yên)
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

#Đánh dấu nút đích và nút nguồn
$ns at 0.0 "$n($val(source)) label source"
$ns at 0.0 "$n($val(source)) color blue"
$n($val(source)) color "blue"
$ns at 0.0 "$n($val(dest)) label destination"
$ns at 0.0 "$n($val(dest)) color orange"
$n($val(dest)) color "orange"
   
#Luồng TCP
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n($val(source)) $tcp
$ns attach-agent $n($val(dest)) $sink
$ns connect $tcp $sink

#Luồng FTP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.1 "$ftp start"
$ns at $val(stop) "$ftp stop"

#Định danh kết nối TCP để phân biệt
$tcp set fid_ 1

#Luồng UPD và null
set udp [new Agent/UDP]
$ns attach-agent $n($val(source)) $udp
set null [new Agent/Null]
$ns attach-agent $n($val(dest)) $null
$ns connect $udp $null

#Định danh kết nối UDP để phân biệt
$udp set fid_ 2

#Thủ tục để kết thúc mô phỏng và mở NAM
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
