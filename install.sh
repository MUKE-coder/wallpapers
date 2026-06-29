#!/usr/bin/env bash
# Wallpapers installer (macOS / Linux)
# Usage: curl -fsSL https://raw.githubusercontent.com/MUKE-coder/wallpapers/main/install.sh | bash

set -euo pipefail

REPO="MUKE-coder/wallpapers"
BRANCH="main"
DEST="$HOME/Pictures/wallpapers"
INTERVAL=5  # minutes between rotations

echo "==> Installing wallpapers to $DEST"
mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Downloading https://github.com/$REPO (branch $BRANCH)"
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP"
SRC="$TMP/wallpapers-$BRANCH"

# Copy only image files
COUNT=0
for f in "$SRC"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
  [ -e "$f" ] || continue
  cp "$f" "$DEST/"
  COUNT=$((COUNT + 1))
done
echo "==> Installed $COUNT wallpapers"

# Write rotation script
ROTATE="$DEST/rotate-wallpaper.sh"
cat > "$ROTATE" << 'EOF'
#!/usr/bin/env bash
DIR="$HOME/Pictures/wallpapers"
PICK="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | shuf -n 1 2>/dev/null || find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | awk 'BEGIN{srand()} {a[NR]=$0} END{print a[int(rand()*NR)+1]}')"
[ -z "$PICK" ] && exit 0

case "$(uname -s)" in
  Darwin)
    /usr/bin/osascript -e "tell application \"System Events\" to set picture of every desktop to \"$PICK\""
    ;;
  Linux)
    # Best-effort across desktop environments. Cron needs these vars to talk to the session bus.
    export DISPLAY="${DISPLAY:-:0}"
    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
      PID="$(pgrep -u "$USER" -n gnome-session 2>/dev/null || pgrep -u "$USER" -n plasmashell 2>/dev/null || pgrep -u "$USER" -n xfce4-session 2>/dev/null || true)"
      if [ -n "$PID" ] && [ -r "/proc/$PID/environ" ]; then
        export DBUS_SESSION_BUS_ADDRESS="$(tr '\0' '\n' < "/proc/$PID/environ" | grep '^DBUS_SESSION_BUS_ADDRESS=' | cut -d= -f2-)"
      fi
    fi
    if command -v gsettings >/dev/null 2>&1; then
      gsettings set org.gnome.desktop.background picture-uri "file://$PICK" 2>/dev/null || true
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$PICK" 2>/dev/null || true
    elif command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
      plasma-apply-wallpaperimage "$PICK"
    elif command -v xfconf-query >/dev/null 2>&1; then
      xfconf-query -c xfce4-desktop -l | grep last-image | while read -r prop; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$PICK"
      done
    elif command -v feh >/dev/null 2>&1; then
      feh --bg-fill "$PICK"
    fi
    ;;
esac
EOF
chmod +x "$ROTATE"

# Apply first wallpaper immediately
"$ROTATE" || true

# Schedule rotation
case "$(uname -s)" in
  Darwin)
    LABEL="com.mukecoder.wallpapers"
    PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
    mkdir -p "$HOME/Library/LaunchAgents"
    cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$ROTATE</string>
  </array>
  <key>StartInterval</key><integer>$((INTERVAL * 60))</integer>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF
    launchctl unload "$PLIST" 2>/dev/null || true
    launchctl load "$PLIST"
    echo "==> Rotating every $INTERVAL minutes (launchd: $LABEL)"
    echo "    Uninstall: launchctl unload $PLIST && rm $PLIST"
    ;;
  Linux)
    CRON_LINE="*/$INTERVAL * * * * $ROTATE >/dev/null 2>&1"
    ( crontab -l 2>/dev/null | grep -vF "$ROTATE"; echo "$CRON_LINE" ) | crontab -
    echo "==> Rotating every $INTERVAL minutes (cron)"
    echo "    Uninstall: crontab -l | grep -v '$ROTATE' | crontab -"
    ;;
  *)
    echo "Unknown OS — wallpapers installed but rotation not scheduled."
    ;;
esac
