#!/bin/bash

echo "[+] Updating package lists..."
sudo apt update

echo "[+] Installing Golang..."
sudo apt install -y golang

echo "[+] Installing Assetfinder..."
go install github.com/tomnomnom/assetfinder@latest

echo "[+] Installing Amass..."
sudo apt install -y amass

echo "[+] Installing Httprobe..."
go install github.com/tomnomnom/httprobe@latest

echo "[+] Installing Subjack..."
go install github.com/haccer/subjack@latest

echo "[+] Installing Waybackurls..."
go install github.com/tomnomnom/waybackurls@latest

echo "[+] Installing Gowitness..."
go install github.com/sensepost/gowitness@latest

# Ensure the Go binary path is in your PATH
#echo "[+] Adding Go binary path to your PATH..."
#echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc
#source ~/.zshrc

echo "[+] installed successfull, run run.sh"
