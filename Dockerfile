FROM anujdatar/cups

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        unzip \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*


# Сборка и установка драйвера LBP810/1120
RUN git clone https://github.com/caxapyk/capt_lbp810-1120.git && \
    cd capt_lbp810-1120/capt-0.1 && \
    make CFLAGS="-O2 -g -DDEBUG" && \
    make install

# Сборка и установка драйвера XPrinter 365B
RUN pip3 install --break-system-packages PyMuPDF Pillow
COPY xp365b.ppd /usr/share/cups/model/tspl/xp365b.ppd
COPY xprinter-tspl /usr/lib/cups/filter/xprinter-tspl
RUN chmod +x /usr/lib/cups/filter/xprinter-tspl