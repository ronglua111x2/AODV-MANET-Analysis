#!/bin/bash

awk -f throughput_Calc.awk AODV.tr >> output.txt
awk -f N2Ndelay_Calc.awk AODV.tr >> output.txt
awk -f overhead_Calc.awk AODV.tr >> output.txt
awk -f PDRratio_Calc.awk AODV.tr >> output.txt
echo "---------------" >> output.txt