#!/bin/bash

awk -f throughputCalc.awk 20.tr >> output.txt
awk -f delayCalc.awk 20.tr >> output.txt
awk -f overheadCalc.awk 20.tr >> output.txt
awk -f paket_delivery_ratio.awk 20.tr >> output.txt
echo "---------------" >> output.txt