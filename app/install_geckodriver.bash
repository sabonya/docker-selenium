#!/usr/bin/bash

apt-get install -y jq
install_dir="/usr/local/bin"
json=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest)
if [ "$(uname)" == "Darwin" ]; then
    url=$(echo "$json" | jq -r '.assets[].browser_download_url | select(contains("macos")) | select(contains("asc")|not)');
elif [ "$(uname)" == "Linux" ]; then
    url=$(echo "$json" | jq -r '.assets[].browser_download_url | select(contains("linux64")) | select(contains("asc")|not)');
else
    echo "can't determine OS";
    exit 1;
fi
curl -s -L "$url" | tar -xz
chmod +x geckodriver
mv geckodriver "$install_dir"
echo "installed geckodriver binary in $install_dir"
