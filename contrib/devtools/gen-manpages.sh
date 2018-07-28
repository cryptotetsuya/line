#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

MIRCOIND=${MIRCOIND:-$SRCDIR/mircoind}
MIRCOINCLI=${MIRCOINCLI:-$SRCDIR/mircoin-cli}
MIRCOINTX=${MIRCOINTX:-$SRCDIR/mircoin-tx}
MIRCOINQT=${MIRCOINQT:-$SRCDIR/qt/mircoin-qt}

[ ! -x $MIRCOIND ] && echo "$MIRCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
MIRVER=($($MIRCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$MIRCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $MIRCOIND $MIRCOINCLI $MIRCOINTX $MIRCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${MIRVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${MIRVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m