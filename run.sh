#!/bin/bash

url=$1

if [ ! -d "$url" ]; then
    mkdir $url
fi

if [ ! -d "$url/recon" ]; then
    mkdir $url/recon
fi

if [ ! -d "$url/recon/gowitness" ]; then
    mkdir $url/recon/gowitness
fi

if [ ! -d "$url/recon/scans" ]; then
    mkdir $url/recon/scans
fi

if [ ! -d "$url/recon/httprobe" ]; then
    mkdir $url/recon/httprobe
fi

if [ ! -d "$url/recon/potential_takeovers" ]; then
    mkdir $url/recon/potential_takeovers
fi

if [ ! -d "$url/recon/wayback" ]; then
    mkdir $url/recon/wayback
fi

if [ ! -d "$url/recon/wayback/params" ]; then
    mkdir $url/recon/wayback/params
fi

if [ ! -d "$url/recon/wayback/extensions" ]; then
    mkdir $url/recon/wayback/extensions
fi

if [ ! -f "$url/recon/httprobe/alive.txt" ]; then
    touch $url/recon/httprobe/alive.txt
fi

if [ ! -f "$url/recon/final.txt" ]; then
    touch $url/recon/final.txt
fi

if [ ! -f "$url/recon/gowitness/gowitness.json" ]; then
    touch $url/recon/gowitness/gowitness.json
fi

echo "[+] subdomains..."
assetfinder $url > $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/final.txt
rm $url/recon/assets.txt

echo ""

echo "[+] more subdomains..."
amass enum -d $url >> $url/recon/f.txt
sort -u $url/recon/f.txt >> $url/recon/final.txt
rm $url/recon/f.txt

echo ""

echo "[+] alive domains..."
cat $url/recon/final.txt | sort -u | httprobe | sed 's/https\?:\/\///' | sed 's/http\?:\/\///' | tee -a $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt

echo ""

echo "[+] subdomain takeover..."
if [ ! -f "$url/recon/potential_takeovers/potential_takeovers.txt" ]; then
    touch $url/recon/potential_takeovers/potential_takeovers.txt
fi
subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c /usr/share/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt 

echo ""

echo "[+] Scanning for open ports..."
nmap -iL $url/recon/httprobe/alive.txt -Pn -n -T1 -sV -oA $url/recon/scans/scanned.txt

echo ""

echo "[+] Scraping wayback data..."
cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
sort -u $url/recon/wayback/wayback_output.txt

echo ""

echo "[+] Pulling and compiling all possible params found in wayback data..."
cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
for line in $(cat $url/recon/wayback/params/wayback_params.txt); do echo $line'='; done

echo ""

echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat $url/recon/wayback/wayback_output.txt); do
    ext="${line##*.}"
    if [[ "$ext" == "js" ]]; then
        echo $line >> $url/recon/wayback/extensions/js1.txt
        sort -u $url/recon/wayback/extensions/js1.txt >> $url/recon/wayback/extensions/js.txt
    fi
    if [[ "$ext" == "html" ]]; then
        echo $line >> $url/recon/wayback/extensions/jsp1.txt
        sort -u $url/recon/wayback/extensions/jsp1.txt >> $url/recon/wayback/extensions/jsp.txt
    fi
    if [[ "$ext" == "json" ]]; then
        echo $line >> $url/recon/wayback/extensions/json1.txt
        sort -u $url/recon/wayback/extensions/json1.txt >> $url/recon/wayback/extensions/json.txt
    fi
    if [[ "$ext" == "php" ]]; then
        echo $line >> $url/recon/wayback/extensions/php1.txt
        sort -u $url/recon/wayback/extensions/php1.txt >> $url/recon/wayback/extensions/php.txt
    fi
    if [[ "$ext" == "aspx" ]]; then
        echo $line >> $url/recon/wayback/extensions/aspx1.txt
        sort -u $url/recon/wayback/extensions/aspx1.txt >> $url/recon/wayback/extensions/aspx.txt
    fi
done

rm $url/recon/wayback/extensions/js1.txt
rm $url/recon/wayback/extensions/jsp1.txt
rm $url/recon/wayback/extensions/json1.txt
rm $url/recon/wayback/extensions/php1.txt
rm $url/recon/wayback/extensions/aspx1.txt

echo ""

echo "[+] Running gowitness against all compiled domains..."
gowitness file -f $url/recon/httprobe/alive.txt -D $url/recon/gowitness

echo ""

echo "[+] done, $url/recon"
