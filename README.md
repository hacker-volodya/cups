# Akiba CUPS
Provides a Docker image for CUPS with:

- Canon LBP-810 CAPT driver (`capt_lbp810-1120`)
- `x365b.ppd` and `xprinter-tspl`, adapted from https://github.com/prodocik/xprinter-xp-v3-linux/

## Installation
1. Copy compose.yml to server with attached printer
2. `docker compose up -d --build`
3. Discover stable USB URI: `docker compose exec cups lpinfo -v`
4. Add Canon LBP-810:
   `docker compose exec cups lpadmin -p Canon-LBP-810 -E -v 'usb://...' -P /usr/share/cups/model/Canon-LBP-810-capt.ppd`
5. Add XPrinter:
   `docker compose exec cups lpadmin -p XPrinter -E -v 'usb://...' -P /usr/share/cups/model/xp365b.ppd`
6. Go to `http://<host>:631` -> Printers -> Canon-LBP-810 -> setup default parameters -> Miscellaneous -> Reset printer before printing -> AlwaysReset
7. Add the network printer to your client OS by IPP/LPD using host `<host>:631`

## Avahi Setup
Install avahi:
```bash
apt install avahi-daemon
```

To enable printer discovery on the network, add files: 

`/etc/avahi/services/cups-lbp810.service`:
```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">Canon LBP-810 on %h</name>

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
</service-group>
```

`/etc/avahi/services/cups-xprinter.service`
```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">XPrinter TDP245 on %h</name>
  <service>
    <type>_ipp._tcp</type>
    <subtype>_universal._sub._ipp._tcp</subtype>
    <port>631</port>
    <txt-record>txtvers=1</txt-record>
    <txt-record>qtotal=1</txt-record>
    <txt-record>rp=printers/XPrinter</txt-record>
    <txt-record>ty=XPrinter</txt-record>
    <txt-record>product=(TSPL printer via CUPS)</txt-record>
    <txt-record>adminurl=http://%h:631/printers/XPrinter</txt-record>
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
