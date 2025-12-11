# Akiba CUPS
Provides Docker image for CUPS with pre-installed Canon LBP-810 driver (https://github.com/caxapyk/capt_lbp810-1120).

## Installation
1. Copy compose.yml to server with attached printer
2. `docker compose up -d`
3. Add printer: `docker compose exec cups-lbp810 lpadmin -p Canon-LBP-810 -P /usr/share/cups/model/Canon-LBP-810-capt.ppd -E`
3. Go to `http://<host>:631` -> Printers -> Canon-LBP-810 -> setup default parameters -> Miscellaneous -> Reset printer before printing -> AlwaysReset
4. Add network printer to your favourite OS by protocol LPD and host `<host>:631`