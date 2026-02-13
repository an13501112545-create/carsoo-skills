---
name: gmail-client-PM
description: Read and send emails via Gmail. Use to list unread messages, read specific emails by ID, or send new emails.
---
# Gmail Client (PM)

Original upstream skill is a Python IMAP/SMTP tool requiring:
- GMAIL_USER
- GMAIL_PASS (Google App Password)

In our OpenClaw sandbox, python3 may not be available, so this skill is implemented as a shell wrapper.
Next step will wire it to the OpenClaw/GOG Gmail capability.

## Usage (current)
- list:  carskills run gmail_client_pm action=list
- read:  carskills run gmail_client_pm action=read id=<message_id>
- send:  carskills run gmail_client_pm action=send to=<email> subject="..." body="..."

## Required env (for real send/read)
- GMAIL_USER
- GMAIL_PASS
