#!/usr/bin/env python3
import json,sys

def main():
    name = "World"
    if len(sys.argv) > 1:
        # accept: name=Chris
        for a in sys.argv[1:]:
            if a.startswith("name="):
                name = a.split("=",1)[1].strip() or name
    print(json.dumps({"ok": True, "message": f"Hello, {name}!"}))
if __name__ == "__main__":
    main()
