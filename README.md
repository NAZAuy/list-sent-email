# listsentem

`listsentem.sh` is a read-only Postfix log viewer for quickly reviewing outbound email activity from a hosting server.

It is designed to help an administrator notice unexpected destinations, for example:

- A business mailbox sending to unfamiliar domains.
- A compromised contact form sending messages to unrelated recipients.
- A local website or system account generating unexpected outbound traffic.
- Deferred or bounced deliveries that may indicate abuse, misconfiguration, or reputation problems.

The script does not block mail, change Postfix, modify firewall rules, or take automatic action.

## Features

- Shows the most recent delivery records from `/var/log/maillog`.
- Shows outbound SMTP deliveries by default.
- Shows sender, recipient, recipient domain, queue ID, technical source, relay, status, and transport.
- Identifies local injection by UID when Postfix records a `pickup` event.
- Identifies remote SMTP clients by IP when Postfix records an `smtpd` event.
- Shows the authenticated SMTP account when it is available in the log.
- Uses colors for `sent`, `deferred`, and `bounced` statuses in interactive terminals.
- Supports `NO_COLOR=1` for scripts, logs, and plain output.
- Provides an optional `--all` mode for local LMTP, local, virtual, and pipe deliveries.

## Requirements

- Bash 4 or newer.
- Perl.
- Root or equivalent read access to `/var/log/maillog`.
- Postfix logging to `/var/log/maillog`.

The script was tested on:

- AlmaLinux 9.8.
- CentOS Web Panel (CWP) v1.8.
- Postfix with `/var/log/maillog`.
- A server using Dovecot for local mailbox delivery.

## Installation

Copy the script to a directory and make it executable:

```bash
chmod 750 ~/scripts/listsentem.sh
```

The script is intentionally kept independent of CWP paths and configuration. It reads the standard Postfix mail log only.

## Usage

Show the last 20 outbound SMTP delivery records:

```bash
sudo ~/scripts/listsentem.sh
```

Show the last 50 records:

```bash
sudo ~/scripts/listsentem.sh 50
```

Show all supported delivery transports, including local deliveries:

```bash
sudo ~/scripts/listsentem.sh --all 100
```

Show help:

```bash
~/scripts/listsentem.sh --help
```

Disable colors:

```bash
NO_COLOR=1 sudo ~/scripts/listsentem.sh 50
```

## Output

The default output contains records using the `smtp` transport. These are deliveries from this Postfix instance to another SMTP server.

```bash
└─> sudo ~/SysAdmin/git/listsentem.sh --all 20
Last 20 all transports
Log: /var/log/maillog
DATE-TIME         QUEUE ID       SENDER                   RECIPIENT                DOMAIN              TECHNICAL SOURCE        RELAY                 STATUS   VIA
Abr  9 09:37:45   A8FASDFGAFA3   service@intl.paypal.com  naza34@gmail.com         gmail.com            SMTP 66.211.170.90       gmail-smtp-in.l.goog sent     smtp
Abr  9 09:38:01   310ASDFGAFA3   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr  9 00:44:28   769ASDFGAFA3   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr  9 00:45:27   948ASDFGAFA3   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr  9 01:04:20   8EEASDFGAFA4   RecepcionCFE@bse.com.uy  cruz20vlam@gmail.com     gmail.com            SMTP 179.27.50.236       gmail-smtp-in.l.goog sent     smtp
Abr  9 02:02:11   6AAASDFGAFA4   Facturacit@scotiab       cruz20vlam@gmail.com     gmail.com            SMTP 66.159.250.235      gmail-smtp-in.l.goog sent     smtp
Abr  9 02:10:48   077ASDFGAFA4   RecepcionCFE@bse.com.uy  cruz20vlam@gmail.com     gmail.com            SMTP 179.27.50.236       gmail-smtp-in.l.goog sent     smtp
Abr  9 02:41:08   4F7ASDFGAFA4   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr  9 02:59:48   5F6ASDFGAFA4   asdfsdfa@hotmail.com     laboratorio@ventarolasur ventarolasuracruz.uy SMTP 52.103.7.41       srvnazsar.com.nz[priva sent     lmtp
Abr  9 03:14:57   A1EASDFGAFA4   asdfsdfa@hotmail.com     laboratorio@ventarolasur ventarolasuracruz.uy SMTP 52.103.10.92      srvnazsar.com.nz[priva sent     lmtp
Abr  9 03:37:47   83FASDFGAFA4   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr  9 03:44:18   52CASDFGAFA4   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr  9 03:55:54   921ASDFGAFA4   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr 10 00:03:35   333ASDFGAFA4   efactura.asdfassadfaad   cruz20vlam@gmail.com     gmail.com            SMTP 209.85.214.182      gmail-smtp-in.l.goog sent     smtp
Abr 10 00:03:36   CDFASDFGAFA4   efactura.asdfassadfaad   cruz20vlam@gmail.com     gmail.com            SMTP 209.85.210.171      gmail-smtp-in.l.goog sent     smtp
Abr 10 00:03:37   4C2ASDFGAFA4   efactura.asdfassadfaad   cruz20vlam@gmail.com     gmail.com            SMTP 209.85.216.49       gmail-smtp-in.l.goog sent     smtp
Abr 10 00:15:01   487ASDFGAFA4   alert@srvnazsar.com.nz   naza34@gmail.com         gmail.com            local root (UID 0)       gmail-smtp-in.l.goog sent     smtp
Abr 10 00:20:20   61AASDFGAFA4   todog@srvnazsar.com.nz   gestion@gastoal.uy       gastoal.uy           local gastoal (UID 100 srvnazsar.com.nz[priva sent     lmtp
Abr 10 00:20:20   7FAASDFGAFA5   todog@srvnazsar.com.nz   admin@goal.com.nz        goal.com.nz          local gastoal (UID 100 srvnazsar.com.nz[priva sent     lmtp
Abr 10 02:00:04   138ASDFGAFA4   ro@srvnazsar.com.nz      ro@srvnazsar.com.nz    srvnazsar.com.nz       local root (UID 0)       local                sent     local
```

Important fields:

- `DATE-TIME`: Timestamp written by Postfix.
- `QUEUE ID`: Postfix message identifier used to trace the message.
- `SENDER`: Envelope sender recorded by Postfix.
- `RECIPIENT`: Effective recipient used for delivery.
- `DOMAIN`: Domain extracted from the recipient address for quick visual review.
- `TECHNICAL SOURCE`: SMTP client IP, authenticated account, or local UID when available.
- `RELAY`: Remote mail server selected by Postfix.
- `STATUS`: Usually `sent`, `deferred`, or `bounced`.
- `VIA`: Postfix delivery transport.

The recipient domain is intentionally displayed separately. An unfamiliar domain can be a useful indicator of a compromised mailbox, website form, account, or application, but it must be reviewed in context.

## Transport meanings

The default mode displays `smtp` only because the primary purpose is to review mail leaving the server toward external mail systems.

- `smtp`: Delivery to another SMTP server, normally an external destination.
- `lmtp`: Local Mail Transfer Protocol, commonly Postfix delivering to Dovecot through a local socket.
- `local`: Delivery to a local system mailbox such as `root`.
- `virtual`: Delivery to a locally hosted virtual mailbox.
- `pipe`: Delivery to a local command or filter.

Use `--all` when local delivery activity is also relevant.

## Interpreting the technical source

Examples:

```text
SMTP 203.0.113.25
SMTP account@example.com @ 203.0.113.25
local www-data (UID 1005)
unknown
```

- `SMTP IP` means Postfix associated the message with a remote SMTP client.
- `SMTP account @ IP` means an authenticated SMTP account was recorded.
- `local USER (UID N)` means the message entered Postfix through the local `pickup` service under that UID.
- `unknown` means the delivery record was found but the available log section did not contain a matching `pickup` or `smtpd` record.

`unknown` is not proof of compromise. It is only a limitation of the available log correlation.

## Security and privacy

The script is read-only and does not send test messages. It may display email addresses, domains, IP addresses, and queue IDs. Treat its output as operationally sensitive and avoid publishing real production output in public repositories or issue trackers.

The script does not identify the exact PHP file that generated a message. It is intended as a fast visual indicator of outbound activity, not as a complete forensic attribution tool.

## Limitations

- It reads the current `/var/log/maillog` file only.
- It does not automatically inspect rotated logs.
- A row represents a Postfix delivery record; one message with several recipients may produce several rows.
- `From` is the envelope sender and can be application-controlled or forged by a local form.
- Domain names and country-code top-level domains are indicators, not proof of malicious activity.
- Rejected SMTP attempts are not delivery records and do not appear in the default output because they never entered the Postfix queue.

## Validation

The script was validated on AlmaLinux 9.8 with CWP v1.8 using:

```bash
bash -n ~/scripts/listsentem.sh
sudo ~/scripts/listsentem.sh 5
sudo ~/scripts/listsentem.sh --all 5
NO_COLOR=1 sudo ~/scripts/listsentem.sh 5
```

The validation confirmed that the script:

- Parses the local Postfix log without changing mail services.
- Displays external SMTP deliveries in default mode.
- Includes local delivery transports in `--all` mode.
- Handles colored and non-colored output.
- Rejects invalid record counts.
