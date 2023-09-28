#!/bin/bash
#Description: Pulls all Beacons (AP/SSID) and Probe Requests (Station MAC/SSID) from specified Wi-Fi .pcap and writes to file.
#Usage: ./pcap-peak <pcap>
pcap=$1


#Strip Beacon Source addresses and SSIDs
tshark -r $pcap  -Y "wlan.fc.type_subtype == 8" -T fields -e wlan.sa -e wlan.ssid | sort | uniq >> $pcap.beacons

#Build Header
echo "            Beacons           " > Output.$pcap.txt 
echo "      BSSID    -| |-   SSID   " >> Output.$pcap.txt 

#Convert SSIDs and write to file
while read -r line; do
  mac=$(echo "$line" | cut -f1)   # extract MAC address
  value=$(echo "$line" | cut -f2) # extract SSID value
  converted=$(echo "$value" | xxd -r -p) # convert SSID value using xxd
  echo "$mac $converted" >> Output.$pcap.txt
done < $pcap.beacons


#Strip Probe Request Source addresses and SSIDs
tshark -r $pcap  -Y "wlan.fc.type_subtype == 4" -T fields -e wlan.sa -e wlan.ssid | sort | uniq >> $pcap.probes

#Build header
echo "             Probes           " >> Output.$pcap.txt 
echo "     STAMAC    -| |-   SSID   " >> Output.$pcap.txt
#Convert SSIDs and append to file
while read -r line; do
  mac=$(echo "$line" | cut -f1)   # extract MAC address
  value=$(echo "$line" | cut -f2) # extract SSID value
  converted=$(echo "$value" | xxd -r -p) # convert SSID value using xxd
  echo "$mac $converted" >> Output.$pcap.txt 
done < $pcap.probes

#Cleanup
rm $pcap.probes $pcap.beacons

#Print output
cat Output.$pcap.txt
