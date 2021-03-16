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
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir selenium beautifulsoup4

# フォントの設定。Dockerfileと同じ場所にIPAフォントを配置しておく。
# https://moji.or.jp/ipafont/ipafontdownload/
RUN mkdir -p /root/.fonts
COPY ./IPAexfont00401/ipaexg.ttf /root/.fonts/.
COPY ./IPAexfont00401/ipaexm.ttf /root/.fonts/.

# [download and install latest geckodriver for linux or mac (selenium webdriver)](https://gist.github.com/cgoldberg/4097efbfeb40adf698a7d05e75e0ff51 "download and install latest geckodriver for linux or mac (selenium webdriver)")
COPY ./app/install_geckodriver.bash /app/
RUN bash /app/install_geckodriver.bash

# Define default command.
CMD ["/bin/bash"]
