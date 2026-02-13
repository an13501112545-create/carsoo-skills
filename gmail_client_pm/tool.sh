#!/usr/bin/env sh
set -eu

# parse key=value args
action=""
id=""
to=""
subject=""
body=""
for a in "$@"; do
  case "$a" in
    action=*) action="${a#action=}" ;;
    id=*) id="${a#id=}" ;;
    to=*) to="${a#to=}" ;;
    subject=*) subject="${a#subject=}" ;;
    body=*) body="${a#body=}" ;;
  esac
done

# Load creds from host-managed env file if the caller didn't provide them.
# This avoids hardcoding secrets in openclaw.json; only /etc/openclaw is mounted read-only.
if [ -z "${GMAIL_USER:-}" ] || [ -z "${GMAIL_APP_PASS:-}" ]; then
  if [ -f /etc/openclaw/gmail.env ]; then
    # shellcheck disable=SC1091
    . /etc/openclaw/gmail.env || true
  fi
fi

json_escape() {
  # minimal escape for JSON strings
  printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g'
}

if [ -z "$action" ]; then
  echo "{\"ok\":false,\"error\":\"missing action=...\",\"hint\":\"use action=list|read|send|diag\"}"
  exit 2
fi

case "$action" in
  diag)
    if [ -n "${GMAIL_USER:-}" ] && [ -n "${GMAIL_APP_PASS:-}" ]; then
      echo "{\"ok\":true,\"smtp\":\"ready\",\"gmail_user\":\"$(json_escape "$GMAIL_USER")\"}"
    else
      echo "{\"ok\":false,\"smtp\":\"missing_env\",\"need\":[\"GMAIL_USER\",\"GMAIL_APP_PASS\"],\"hint\":\"Set env vars for SMTP (App Password).\"}"
    fi
    ;;
  send)
    [ -n "$to" ] || { echo "{\"ok\":false,\"error\":\"missing to=...\"}"; exit 4; }
    [ -n "$subject" ] || { echo "{\"ok\":false,\"error\":\"missing subject=...\"}"; exit 5; }
    [ -n "$body" ] || { echo "{\"ok\":false,\"error\":\"missing body=...\"}"; exit 6; }
    [ -n "${GMAIL_USER:-}" ] || { echo "{\"ok\":false,\"error\":\"missing env GMAIL_USER\"}"; exit 7; }
    [ -n "${GMAIL_APP_PASS:-}" ] || { echo "{\"ok\":false,\"error\":\"missing env GMAIL_APP_PASS\"}"; exit 8; }

    # Build a simple RFC822 message
    msg_file="$(mktemp)"
    {
      echo "From: ${GMAIL_USER}"
      echo "To: ${to}"
      echo "Subject: ${subject}"
      echo "MIME-Version: 1.0"
      echo "Content-Type: text/plain; charset=UTF-8"
      echo
      printf "%s\n" "$body"
    } > "$msg_file"

    # SMTP send via curl
    if command -v curl >/dev/null 2>&1; then
      set +e
      out="$(curl -sS --url 'smtps://smtp.gmail.com:465' \
        --ssl-reqd \
        --user "${GMAIL_USER}:${GMAIL_APP_PASS}" \
        --mail-from "${GMAIL_USER}" \
        --mail-rcpt "${to}" \
        --upload-file "$msg_file" 2>&1)"
      code=$?
      set -e
      rm -f "$msg_file" || true
      if [ $code -eq 0 ]; then
        echo "{\"ok\":true,\"sent\":true,\"to\":\"$(json_escape "$to")\"}"
      else
        echo "{\"ok\":false,\"sent\":false,\"curl_code\":$code,\"error\":\"$(json_escape "$out")\"}"
        exit 9
      fi
    else
      rm -f "$msg_file" || true
      echo "{\"ok\":false,\"error\":\"curl not found\"}"
      exit 10
    fi
    ;;
  list|read)
    echo "{\"ok\":false,\"error\":\"not wired yet\",\"next\":\"We'll add Gmail read/list after SMTP send works.\"}"
    ;;
  *)
    echo "{\"ok\":false,\"error\":\"unknown action\",\"action\":\"$(json_escape "$action")\"}"
    exit 11
    ;;
esac
