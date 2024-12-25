#!/bin/bash

awk -f throughputCalc.awk AODV.tr >> output.txt
awk -f delayCalc.awk AODV.tr >> output.txt
awk -f overheadCalc.awk AODV.tr >> output.txt
awk -f paket_delivery_ratio.awk AODV.tr >> output.txt
echo "---------------" >> output.txt