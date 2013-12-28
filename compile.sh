#!/bin/sh

ATTEMPTS=10
PID=$$
ME=`basename $0`
MAXPROC=3
W=$PID.pid

die() { echo $ME[$PID]: $@ >&2; exit 1; }
warn() { echo $ME[$PID]: $@ >&2; }

mkdir run 2>/dev/null
cd run || die "Can't cd to run directory"

while test -n "$1" ; do
  case "$1" in
    -a|--attempts) ATTEMPTS=$2 ; shift ;;
    -m|--max) MAXPROC=$2; shift ;;
    *) die "Unknown command line option $1" ;;
  esac
  shift
done

lock() {
    while true; do
      if test "$ATTEMPTS" = "0" ; then
        die "No attempts left"
      fi
      ATTEMPTS=$(expr $ATTEMPTS '-' 1)

      (
      flock -n 9 || exit 1
        for f in *pid ; do
          ps fax | grep -v grep | grep -q -w $(cat $f/pidfile) || {
            warn "Purging $f"
            rm -rf $f
          }
        done
        N=$(ls -d -1 *pid 2>/dev/null | wc -l)
        if expr $N '<' $MAXPROC ; then
          mkdir $PID.pid
          echo $PID > $PID.pid/pidfile
          exit 0
        fi
        exit 1
      ) 9>lockfile

      if test "$?" != "0" ; then
        warn "Waiting for free slots"
        sleep 1
        continue
      fi
      warn "Obtained the lock"
      break
    done
}

lock

cat > $W/source.ur
urweb -dumpTypes $W/source 2>$W/errors
ret=$?

cat $W/errors
echo "$ret"

