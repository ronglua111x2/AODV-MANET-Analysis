#!/bin/bash

awk -f throughput_Calc.awk AODV.tr >> output.txt
awk -f delay_Calc.awk AODV.tr >> output.txt
awk -f overheadCalc.awk AODV.tr >> output.txt
awk -f PDRratio_Calc.awk AODV.tr >> output.txt
echo "---------------" >> output.txt