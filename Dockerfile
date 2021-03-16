
# FROM python:latest

# ENV PYTHONIOENCODING utf-8
# WORKDIR /app

# RUN apk add --update \
#     # wget \
#     # Add chromium and dependences
#     # udev \
#     # ttf-freefont \
#     # chromium \
#     # chromium-chromedriver \
#     # geckodriver \
#     # Add Japanese font
#     && mkdir noto \
#     && wget -P /app/noto https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip \
#     && unzip /app/noto/NotoSansCJKjp-hinted.zip -d /app/noto \
#     && mkdir -p /usr/share/fonts/noto \
#     && cp /app/noto/*.otf /usr/share/fonts/noto \
#     && chmod 644 -R /usr/share/fonts/noto/ \
#     && fc-cache -fv \
#     && rm -rf /app/noto \
#     # Add selenium
#     && pip install selenium

# [【日記】dockerでpython+selenium環境構築｜Kei｜note](https://note.com/kei198403/n/neac807d407d4 "【日記】dockerでpython+selenium環境構築｜Kei｜note")
FROM ubuntu:20.10
# FROM ubuntu:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ここはchromeのバージョンに合わせて変える。
ARG CHROME_DRIVER_URL=https://chromedriver.storage.googleapis.com/86.0.4240.22/chromedriver_linux64.zip

# 環境変数設定
ENV TZ=Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG ja_JP.UTF-8
ENV PYTHONIOENCODIND utf_8

# 色々とインストール
RUN \
    apt-get update && \
    apt-get install -y python3.8 curl wget unzip python3.8-distutils gnupg sudo apt-utils tzdata && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    wget -q https://bootstrap.pypa.io/get-pip.py && \
    rm -f /usr/bin/python /usr/bin/python3 && \
    ln /usr/bin/python3.8 /usr/bin/python && \
    ln /usr/bin/python3.8 /usr/bin/python3 && \
    python3 get-pip.py && \
    wget $CHROME_DRIVER_URL && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/. && \
    rm -f chromedriver_linux64.zip && \
    rm -f get-pip.py && \
    apt-get install -y language-pack-ja-base language-pack-ja
RUN locale-gen ja_JP.UTF-8

# Pythonライブラリインストール
RUN \
    pip install --upgrade pip && \
    pip install selenium beautifulsoup4

# フォントの設定。Dockerfileと同じ場所にIPAフォントを配置しておく。
# https://moji.or.jp/ipafont/ipafontdownload/
RUN mkdir -p /root/.fonts
COPY ./IPAexfont00401/ipaexg.ttf /root/.fonts/.
COPY ./IPAexfont00401/ipaexm.ttf /root/.fonts/.

# RUN \
#     install_dir="/usr/local/bin" && \
#     version=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
#     if [[ $(uname) == "Darwin" ]]; then \
#     url=https://chromedriver.storage.googleapis.com/$version/chromedriver_mac64.zip \
#     elif [[ $(uname) == "Linux" ]]; then \
#     url=https://chromedriver.storage.googleapis.com/$version/chromedriver_linux64.zip \
#     else \
#     echo "can't determine OS" && \
#     exit 1 \
#     fi \
#     curl -s -L "$url" | tar -xz && \
#     chmod +x chromedriver && \
#     sudo mv chromedriver "$install_dir" && \
#     echo "installed chromedriver binary in $install_dir"

# [download and install latest geckodriver for linux or mac (selenium webdriver)](https://gist.github.com/cgoldberg/4097efbfeb40adf698a7d05e75e0ff51 "download and install latest geckodriver for linux or mac (selenium webdriver)")
RUN apt-get install -y jq
# RUN \
#     install_dir="/usr/local/bin" && \
#     json=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest) && \
#     if [[ $(uname) == "Darwin" ]]; then \
#     url=$(echo "$json" | jq -r '.assets[].browser_download_url | select(contains("macos")) | select(contains("asc")|not)'); \
#     elif [[ $(uname) == "Linux" ]]; then \
#     url=$(echo "$json" | jq -r '.assets[].browser_download_url | select(contains("linux64")) | select(contains("asc")|not)'); \
#     else \
#     echo "can't determine OS" && \
#     exit 1; \
#     fi && \
#     curl -s -L "$url" | tar -xz && \
#     chmod +x geckodriver && \
#     sudo mv geckodriver "$install_dir" && \
#     echo "installed geckodriver binary in $install_dir"
COPY ./app/install_geckodriver.bash /app/
RUN bash /app/install_geckodriver.bash

# Define default command.
CMD ["/bin/bash"]
