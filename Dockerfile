FROM anujdatar/cups

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        unzip \
    && rm -rf /var/lib/apt/lists/*


# Сборка и установка драйвера LBP810/1120
RUN git clone https://github.com/caxapyk/capt_lbp810-1120.git && \
    cd capt_lbp810-1120/capt-0.1 && \
    make CFLAGS="-O2 -g -DDEBUG" && \
    make install

# Install TSPL filters from the official Linux package and adapt the
# TDP-245 Plus PPD from the Xprinter/TSC macOS bundle to use raster-tspl.
RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    cd "$tmpdir"; \
    curl -L -o idprt.zip "https://www.idprt.com/prt_v2/files/down_file/id/283/fid/668.html"; \
    unzip -q idprt.zip; \
    case "$(dpkg --print-architecture)" in \
        amd64) filter_arch="x64" ;; \
        i386) filter_arch="x86" ;; \
        *) echo "unsupported TSPL driver architecture: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac; \
    install -m 755 "idprt_tspl_printer_linux_driver_v1.4.7/filter/${filter_arch}/raster-tspl" /usr/lib/cups/filter/raster-tspl; \
    install -m 755 "idprt_tspl_printer_linux_driver_v1.4.7/filter/${filter_arch}/raster-esc" /usr/lib/cups/filter/raster-esc; \
    install -d -m 755 /usr/share/cups/model/tspl; \
    install -m 644 idprt_tspl_printer_linux_driver_v1.4.7/ppd/*.ppd /usr/share/cups/model/tspl/; \
    curl -L -o xprinter.zip "http://www.xprinter.com.ua/download/Xprinter_printer_label_MAC_driver.zip"; \
    unzip -q xprinter.zip "TSC_MAC_driver/PPDs/TDP-245 Plus.ppd"; \
    perl -0pe 's/\*FileVersion: "1\.0"/\*FileVersion: "1.0-linux-tspl"/; s/\*PCFileName: "TDP-245 Plus\.ppd"/\*PCFileName: "TDP-245-Plus-tspl.ppd"/; s/\*cupsVersion: 1\.2\n\*cupsManualCopies: False\n\*cupsFilter: "application\/vnd\.cups-raster 0 \/Library\/Printers\/TSC\/Filter\/rastertobarcodetspl"/\*cupsVersion: 1.5\n\*cupsModelNumber: 37155\n\*cupsManualCopies: False\n\*cupsFilter: "application\/vnd.cups-raster 100 raster-tspl"/' "TSC_MAC_driver/PPDs/TDP-245 Plus.ppd" > /usr/share/cups/model/tspl/TDP-245-Plus-tspl.ppd; \
    rm -rf "$tmpdir"
