#!/bin/bash
set -e

#export DRYRUN=echo

typeset -i RC=0

APT_USER="${APT_USER:-cloud}"
APT_HOST="${APT_HOST:-keg.dev.uswest.hpcloud.net}"
APT_ROOT="${APT_ROOT:-/var/www/cloud}"
APT_PROJECT="${APT_PROJECT:-}"
APT_SUBPROJ="${APT_SUBPROJ:-}"
APT_DIST="${APT_DIST:-}"
APT_COMP="${APT_COMP:-}"
APT_ARCH="${APT_ARCH:-}"
REPREPRO_VERBOSE="${REPREPRO_VERBOSE:-}"

[ -n "$*" ] || { echo "Usage: $(basename $0) <deb_pkg> [<deb_pkg>...]"; exit 2; }

#shorthands

AUH=${APT_USER}@${APT_HOST}
AP=${APT_ROOT}/${APT_PROJECT}/${APT_SUBPROJ}

# sanity checks

[ -n "$APT_PROJECT" ] || { echo "Error - APT_PROJECT undefined"; RC=1; }
[ -n "$APT_SUBPROJ" ] || { echo "Error - APT_SUBPROJ undefined"; RC=1; }
[ -n "$APT_DIST" ] || { echo "Error - APT_DIST undefined"; RC=1; }
[ $RC -eq 0 ] || exit $RC

export PUBDEBS=
export UNPUBDEBS=

for DEB in $*; do
	DBN=$(basename $DEB)
	DPN=$(dpkg-deb -f $DEB Source)
	[ -n "${DPN}" ] || DPN=$(dpkg-deb -f $DEB Package) # fallback to Package if Source is undefined
	if [ ! -r $DEB ]; then
		echo "Error - can't read $DEB, ignoring"
		RC=1
	elif [ -n "${DEB##*.deb}" ]; then
		echo "Error - $DEB isn't a proper deb filename, ignoring"
		RC=1
	elif ssh $AUH "[ -f $AP/pool/$APT_COMP/${DPN:0:1}/$DPN/$(basename $DEB) ] && exit 0 || exit 1"; then
		echo "Warning - $DBN already exists on $APT_HOST:$AP, new package not installed, archived for manual replacement if needed"
		UNPUBDEBS+=" $DEB"
	else
		PUBDEBS+=" $DEB"
	fi
done

# publish it/them

if [ "$UNPUBDEBS" ]; then
	DD=$AP/duplicates/$JOB_NAME/$BUILD_NUMBER
	echo "Archiving duplicate debs to $AUH:$DD"
	$DRYRUN ssh $AUH "mkdir -p $DD" && $DRYRUN scp $UNPUBDEBS $AUH:$DD || { echo "Archiving failed"; RC=1; }
fi

if [ "$PUBDEBS" ]; then
	echo -e "Publishing to apt $AP/$APT_DIST on $APT_HOST\n"

	TMPDIR=/tmp/apt_publish.$$

	$DRYRUN ssh $AUH "rm -rf $TMPDIR; mkdir $TMPDIR" && $DRYRUN scp $PUBDEBS $AUH:$TMPDIR || { echo "Error - package upload failed"; exit 1; }

	OPTS=
	[ -z "$APT_COMP" ]         || OPTS+=" --component '$APT_COMP'"
	[ -z "$APT_ARCH" ]         || OPTS+=" --architecture '$APT_ARCH'"
	[ -z "$REPREPRO_VERBOSE" ] || OPTS+=" -V"

	$DRYRUN ssh $AUH "reprepro -b $AP --keepunreferencedfiles --morguedir +b/morgue $OPTS includedeb $APT_DIST $TMPDIR/*" || { echo "Repo add failed"; RC=1; }

	$DRYRUN ssh $AUH rm -rf $TMPDIR
fi

exit $RC
