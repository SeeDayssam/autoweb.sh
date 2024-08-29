#!/bin/bash

url=$1

if [ ! -d "$url" ];then
        mkdir "$url"
fi

if [ ! -d "$url/recon" ];then
        mkdir "$url/recon"

fi 

echo "[+] automated tool by Dy5m for web application hacking [+]"

echo "[+] subdomains with assetfinder...."
assetfinder $url >> "$url/recon/0.txt" 
cat "$url/recon/0.txt" | grep $1 | sort -u >> "$url/recon/1.txt"
rm "$url/recon/0.txt"

#echo "[+] subdomains with amass...."
#amass enum -d $url >> "$url/recon/2.txt"
#sort -u "2.txt" >> "$url/recon/1.txt"
#rm "$url/recon/2.txt"

echo "[+] find alive subdomains with httprobe...."
cat $url/recon/1.txt | sort -u | httprobe | sed 's/https\?:\/\///' | sed 's/http\?:\/\///' >> $url/recon/alive.txt  # | tr -d ':443'
rm $url/recon/1.txt

echo "[+] done, $url/recon/alive.txt"
