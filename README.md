# Akiba CUPS
Provides a Docker image for CUPS with:

- Canon LBP-810 CAPT driver (`capt_lbp810-1120`)
- official Linux TSPL filters from iDPRT (`raster-tspl`, `raster-esc`)
- `TDP-245-Plus-tspl.ppd`, adapted from `TDP-245 Plus.ppd` in `Xprinter_printer_label_MAC_driver.zip`

## Installation
1. Copy compose.yml to server with attached printer
2. `docker compose up -d --build`
3. Discover stable USB URI: `docker compose exec cups lpinfo -v`
4. Add Canon LBP-810 if needed:
   `docker compose exec cups lpadmin -p Canon-LBP-810 -E -v 'usb://...' -P /usr/share/cups/model/Canon-LBP-810-capt.ppd`
5. Add a TSPL/XPrinter queue with the adapted TDP-245 Plus PPD:
   `docker compose exec cups lpadmin -p XPrinter-TDP245 -E -v 'usb://...' -P /usr/share/cups/model/tspl/TDP-245-Plus-tspl.ppd`
6. Go to `http://<host>:631` -> Printers -> Canon-LBP-810 -> setup default parameters -> Miscellaneous -> Reset printer before printing -> AlwaysReset
7. Add the network printer to your client OS by IPP/LPD using host `<host>:631`

The TSPL integration is intended for printers that are compatible with the `TDP-245 Plus.ppd` profile and the Linux `raster-tspl` filter. That includes setups where users report success with the PPD from `http://www.xprinter.com.ua/download/Xprinter_printer_label_MAC_driver.zip`.

With the current compose setup, CUPS sees the real USB bus and can return stable `usb://...` URIs that usually include device identity data such as vendor, model, and serial. Prefer that URI over `/dev/usb/lp*`, because it survives cable replugging and port changes much better.

## Avahi Setup
Install avahi:
```bash
apt install avahi-daemon
```

To enable printer discovery for both queues at once, add `/etc/avahi/services/cups-printers.service`:
```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">CUPS Printers on %h</name>

  <service>
    <type>_ipp._tcp</type>
    <subtype>_universal._sub._ipp._tcp</subtype>
    <port>631</port>

    <txt-record>txtvers=1</txt-record>
    <txt-record>qtotal=1</txt-record>
    <txt-record>rp=printers/Canon-LBP-810</txt-record>
    <txt-record>ty=Canon LBP-810</txt-record>
    <txt-record>product=(Canon LBP-810 via CUPS)</txt-record>
    <txt-record>note=AirPrint via CUPS</txt-record>
    <txt-record>adminurl=http://%h:631/printers/Canon-LBP-810</txt-record>
    <txt-record>URF=none</txt-record>
    <txt-record>pdl=application/pdf,application/postscript,image/urf</txt-record>
    <txt-record>Color=F</txt-record>
    <txt-record>Duplex=F</txt-record>
  </service>

  <service>
    <type>_ipp._tcp</type>
    <subtype>_universal._sub._ipp._tcp</subtype>
    <port>631</port>

    <txt-record>txtvers=1</txt-record>
    <txt-record>qtotal=1</txt-record>
    <txt-record>rp=printers/XPrinter-TDP245</txt-record>
    <txt-record>ty=XPrinter TDP-245 compatible</txt-record>
    <txt-record>product=(TSPL printer via CUPS)</txt-record>
    <txt-record>note=AirPrint via CUPS</txt-record>
    <txt-record>adminurl=http://%h:631/printers/XPrinter-TDP245</txt-record>
    <txt-record>URF=none</txt-record>
    <txt-record>pdl=application/pdf,application/postscript,image/urf</txt-record>
    <txt-record>Color=F</txt-record>
    <txt-record>Duplex=F</txt-record>
  </service>
</service-group>
```

Restart Avahi:
```bash
systemctl restart avahi-daemon
```
