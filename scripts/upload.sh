#!/usr/bin/env bash
set -Eeuo pipefail

# ========= Konfiguration =========
# Lokaler Ordner mit dem fertigen GUI v2 Build (Ordner, NICHT * verwenden)
SRC_DIR="/git/gui-v2/build-wasm_files_to_copy/wasm"
# Zielpfad auf dem GX
DEST_DIR="/var/www/venus/gui-v2"
# Liste von Hosts (Komma-getrennt) kann per -H überschrieben werden
HOST_LIST=""
# =================================

usage() {
  cat <<USAGE
Usage: $0 [-H host1,host2,...] [-s SRC_DIR] [-d DEST_DIR]
  -H    IP(s)/Hostname(s) der GX-Geräte, komma-getrennt (z.B. 192.168.20.5,venus.local)
  -s    Quellordner (Standard: $SRC_DIR)
  -d    Zielordner auf GX (Standard: $DEST_DIR)

Beispiel:
  $0 -H 192.168.20.5 -s /git/gui-v2/build-wasm_files_to_copy/wasm -d /var/www/venus/gui-v2
USAGE
}

# Args
while getopts ":H:s:d:h" opt; do
  case "$opt" in
    H) HOST_LIST="$OPTARG" ;;
    s) SRC_DIR="$OPTARG" ;;
    d) DEST_DIR="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Unbekannte Option: -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

# ---- Vorab-Checks lokal ----
need() { command -v "$1" >/dev/null 2>&1 || { echo "Fehlt: $1"; exit 1; }; }
need ssh; need scp; need nc; need ssh-copy-id

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Quellordner existiert nicht: $SRC_DIR" >&2
  exit 1
fi

# Kopiere NUR den Inhalt: wir hängen '/.' an den Quellpfad
SRC_CONTENT="${SRC_DIR%/}/."

# SSH-Key prüfen/erzeugen
KEY="${HOME}/.ssh/id_rsa"
if [[ ! -f "$KEY" ]]; then
  echo "Kein SSH-Key gefunden – erstelle neuen unter $KEY"
  ssh-keygen -t rsa -b 4096 -f "$KEY" -N "" </dev/tty
fi

if [[ -z "${HOST_LIST}" ]]; then
  echo "Bitte Hosts angeben (-H)."
  usage
  exit 2
fi

# Hosts iterieren (Komma-getrennt)
IFS=',' read -r -a HOSTS <<< "$HOST_LIST"

for HOST in "${HOSTS[@]}"; do
  echo "==============================================="
  echo "== Host: $HOST"
  echo "==============================================="

  # Port 22 erreichbar?
  echo -n "Test TCP/22 auf $HOST ... "
  if nc -z -w 5 "$HOST" 22; then
    echo "OK"
  else
    echo "NICHT erreichbar (Port 22). Überspringe Host."
    continue
  fi

  # Passwortlose SSH testen
  echo -n "Test passwortlose SSH ... "
  if ssh -o BatchMode=yes -o ConnectTimeout=5 root@"$HOST" "exit" 2>/dev/null; then
    echo "OK"
  else
    echo "fehlgeschlagen."
    echo "Übertrage Public Key (du wirst evtl. nach dem Root-Passwort gefragt) ..."
    if ssh-copy-id -o StrictHostKeyChecking=accept-new root@"$HOST"; then
      echo "Key erfolgreich übertragen."
    else
      echo "Key-Übertragung fehlgeschlagen. Überspringe Host."
      continue
    fi
  fi

  # Remount RW
  echo -n "Remount / (rw) ... "
  if ssh root@"$HOST" "/opt/victronenergy/swupdate-scripts/remount-rw.sh"; then
    echo "OK"
  else
    echo "fehlgeschlagen."
    continue
  fi

  # Zielordner anlegen
  echo -n "Erzeuge Zielordner $DEST_DIR ... "
  if ssh root@"$HOST" "mkdir -p '$DEST_DIR'"; then
    echo "OK"
  else
    echo "fehlgeschlagen."
    ssh root@"$HOST" "mount -o remount,ro /" || true
    continue
  fi

  # Kopieren – nur Inhalt (SRC_DIR/.)
  echo "Kopiere Inhalte von $SRC_DIR → $HOST:$DEST_DIR ..."
  if scp -r -q "$SRC_CONTENT" root@"$HOST":"$DEST_DIR"/ ; then
    echo "Kopieren: OK"
  else
    echo "Kopieren: FEHLER"
    echo "Freier Speicher auf GX:"
    ssh root@"$HOST" "df -h | head -n 2" || true
    ssh root@"$HOST" "mount -o remount,ro /" || true
    continue
  fi

  # Optional: Dienst für VRM neu starten (wie im großen Skript)
  echo -n "Restart vrmlogger ... "
  ssh root@"$HOST" "svc -t /service/vrmlogger" >/dev/null 2>&1 && echo "OK" || echo "nicht vorhanden/übersprungen"

  # Remount RO
  echo -n "Remount / (ro) ... "
  ssh root@"$HOST" "mount -o remount,ro /" && echo "OK" || echo "WARNUNG: remount ro fehlgeschlagen"

  echo "Host $HOST: FERTIG."
  echo
done

echo "Alle Hosts abgearbeitet."