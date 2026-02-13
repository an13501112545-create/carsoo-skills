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

if [ -z "$action" ]; then
  echo "{\"ok\":false,\"error\":\"missing action=...\",\"hint\":\"use action=list|read|send\"}"
  exit 2
fi

# We will wire this to GOG/OpenClaw Gmail in the next step.
# For now, validate inputs and environment.
case "$action" in
  diag)
    # check gog availability + list accounts if possible
    if command -v gog >/dev/null 2>&1; then
      echo "{\"ok\":true,\"gog\":\"present\",\"hint\":\"next run: gog auth manage (or login) with --account\"}"
      (gog auth manage --help >/dev/null 2>&1) || true
    else
      echo "{\"ok\":false,\"gog\":\"missing\",\"hint\":\"gog not found in sandbox; we will mount it or use OpenClaw gmail connector\"}"
    fi
    ;;

  list)
    echo "{\"ok\":false,\"error\":\"not wired yet\",\"next\":\"wire to GOG/OpenClaw Gmail; then list unread\"}"
    ;;
  read)
    [ -n "$id" ] || { echo "{\"ok\":false,\"error\":\"missing id=...\"}"; exit 3; }
    echo "{\"ok\":false,\"error\":\"not wired yet\",\"next\":\"wire to GOG/OpenClaw Gmail; then read by id\"}"
    ;;
  send)
    [ -n "$to" ] || { echo "{\"ok\":false,\"error\":\"missing to=...\"}"; exit 4; }
    [ -n "$subject" ] || { echo "{\"ok\":false,\"error\":\"missing subject=...\"}"; exit 5; }
    [ -n "$body" ] || { echo "{\"ok\":false,\"error\":\"missing body=...\"}"; exit 6; }
    echo "{\"ok\":false,\"error\":\"not wired yet\",\"next\":\"wire to GOG/OpenClaw Gmail; then send\"}"
    ;;
  *)
    echo "{\"ok\":false,\"error\":\"unknown action\",\"action\":\"$action\"}"
    exit 7
    ;;
esac
