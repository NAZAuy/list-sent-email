#!/usr/bin/env bash
set -euo pipefail

readonly LOG_FILE="/var/log/maillog"
readonly DEFAULT_N=20
all_transports=0

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    printf 'Usage: sudo bash %s [--all] [N]\n' "$0"
    printf 'Show the last N outbound SMTP delivery records.\n'
    printf 'With --all, include local LMTP, local, virtual, and pipe deliveries.\n'
    printf 'Default: %s records.\n' "$DEFAULT_N"
    exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
    printf 'ERROR: run as root, for example: sudo bash %s 20\n' "$0" >&2
    exit 1
fi

if [[ "${1:-}" == "--all" ]]; then
    all_transports=1
    shift
fi

if [[ "$#" -gt 1 || ( "$#" -eq 1 && ! "${1}" =~ ^[1-9][0-9]*$ ) ]]; then
    printf 'ERROR: N must be a positive integer.\n' >&2
    printf 'Usage: sudo bash %s [--all] [N]\n' "$0" >&2
    exit 2
fi

readonly RECORDS="${1:-$DEFAULT_N}"
readonly TRANSPORTS="$all_transports"

if [[ ! -r "$LOG_FILE" ]]; then
    printf 'ERROR: cannot read %s.\n' "$LOG_FILE" >&2
    exit 1
fi

# Use colors only for interactive output. NO_COLOR disables them explicitly.
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    readonly BOLD=$'\033[1m'
    readonly RESET=$'\033[0m'
    readonly GREEN=$'\033[32m'
    readonly YELLOW=$'\033[33m'
    readonly RED=$'\033[31m'
    readonly CYAN=$'\033[36m'
else
    readonly BOLD=''
    readonly RESET=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly RED=''
    readonly CYAN=''
fi

if [[ "$TRANSPORTS" -eq 1 ]]; then
    scope='all transports'
else
    scope='outbound SMTP deliveries'
fi

printf '%sLast %s %s%s\n' "$BOLD" "$RECORDS" "$scope" "$RESET"
printf '%s\n' "${CYAN}Log: ${LOG_FILE}${RESET}"
printf '%s\n' "${BOLD}DATE-TIME         QUEUE ID       SENDER                   RECIPIENT                DOMAIN              TECHNICAL SOURCE        RELAY                 STATUS   VIA${RESET}"

export POSTFIX_RECORDS="$RECORDS"
export POSTFIX_TRANSPORTS="$TRANSPORTS"

perl -ne '
    # Associate a queue ID with a local process UID and envelope sender.
    if (/postfix\/pickup\[\d+\]:\s+(\w+): uid=(\d+) from=<([^>]*)>/) {
        $uid{$1} = $2;
        $from{$1} = $3;
    }

    # The queue manager also records the envelope sender.
    if (/postfix\/qmgr\[\d+\]:\s+(\w+): from=<([^>]*)>/) {
        $from{$1} = $2;
    }

    # Record the SMTP client IP and, when available, the authenticated account.
    if (/postfix\/smtpd\[\d+\]:\s+(\w+): client=[^\[]+\[([^\]]+)\].*?sasl_username=([^, ]+)/) {
        $source{$1} = "SMTP $3 @ $2";
    } elsif (/postfix\/smtpd\[\d+\]:\s+(\w+): client=[^\[]+\[([^\]]+)\]/) {
        $source{$1} = "SMTP $2";
    }

    # Keep only the requested number of the most recent delivery records.
    if (/^([^ ]+\s+\d+\s+[^ ]+).*postfix\/(smtp|lmtp|local|virtual|pipe)\[\d+\]:\s+(\w+):\s+to=<([^>]+)>.*?relay=([^, ]+).*?status=(\w+)/) {
        my ($when, $transport, $queue, $to, $relay, $status) = ($1, $2, $3, $4, $5, $6);
        next if $ENV{POSTFIX_TRANSPORTS} eq "0" && $transport ne "smtp";

        my $origin = $from{$queue} // "?";
        my ($domain) = $to =~ /@([^@]+)$/;
        $domain //= "local";
        my $technical = $source{$queue};

        if (!defined($technical) && defined($uid{$queue})) {
            my $user = getpwuid($uid{$queue}) // "UID $uid{$queue}";
            $technical = "local $user (UID $uid{$queue})";
        }

        $technical //= "unknown";
        push @rows, join("\034", $when, $queue, $origin, $to, $domain, $technical, $relay, $status, $transport);
        shift @rows while @rows > $ENV{POSTFIX_RECORDS};
    }

    END {
        print "$_\n" for @rows;
    }
' "$LOG_FILE" |
while IFS=$'\034' read -r when queue origin destination domain technical relay status transport; do
    case "$status" in
        sent)     status_color="$GREEN" ;;
        deferred) status_color="$YELLOW" ;;
        bounced)  status_color="$RED" ;;
        *)        status_color="$YELLOW" ;;
    esac

    printf '%-17s %-14s %-24.24s %-24.24s %-20.20s %-24.24s %-20.20s %b%-8s%b %-6s\n' \
        "$when" "$queue" "$origin" "$destination" "$domain" "$technical" "$relay" \
        "$status_color" "$status" "$RESET" "$transport"
done
