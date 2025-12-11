FROM anujdatar/cups

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git \
    && rm -rf /var/lib/apt/lists/*


# Сборка и установка драйвера LBP810/1120
RUN git clone https://github.com/caxapyk/capt_lbp810-1120.git && \
    cd capt_lbp810-1120/capt-0.1 && \
    make CFLAGS="-O2 -g -DDEBUG" && \
    make install