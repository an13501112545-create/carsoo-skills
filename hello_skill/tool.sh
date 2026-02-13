#!/usr/bin/env sh
# Usage: ./tool.sh name=Chris
name="World"
for a in "$@"; do
  case "$a" in
    name=*) name="${a#name=}" ;;
  esac
done
echo "{\"ok\":true,\"message\":\"Hello, ${name}!\"}"
