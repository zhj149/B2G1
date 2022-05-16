#!/bin/bash

REPO=${REPO:-./repo}
sync_flags=""

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml $REPO_INIT_FLAGS &&
	$REPO sync $sync_flags $REPO_SYNC_FLAGS
	ret=$?
	if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
		rm -rf $GIT_TEMP_REPO
	fi
	if [ $ret -ne 0 ]; then
		echo Repo sync failed
		exit -1
	fi
}

case `uname` in
"Darwin")
	# Should also work on other BSDs
	CORE_COUNT=`sysctl -n hw.ncpu`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

GITREPO=${GITREPO:-"git://github.com/mozilla-b2g/b2g-manifest"}
BRANCH=${BRANCH:-master}

while [ $# -ge 1 ]; do
	case $1 in
	-d|-l|-f|-n|-c|-q|-j*)
		sync_flags="$sync_flags $1"
		if [ $1 = "-j" ]; then
			shift
			sync_flags+=" $1"
		fi
		shift
		;;
	--help|-h)
		# The main case statement will give a usage message.
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

GIT_TEMP_REPO="tmp_manifest_repo"
if [ -n "$2" ]; then
	GITREPO=$GIT_TEMP_REPO
	rm -rf $GITREPO &&
	git init $GITREPO &&
	cp $2 $GITREPO/$1.xml &&
	cd $GITREPO &&
	git add $1.xml &&
	git commit -m "manifest" &&
	git branch -m $BRANCH &&
	cd ..
fi

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo GECKO_OBJDIR=$PWD/objdir-gecko >> .tmp-config
echo DEVICE_NAME=$1 >> .tmp-config

case "$1" in
"galaxy-s2")
	echo DEVICE=galaxys2 >> .tmp-config &&
	repo_sync $1
	;;

"galaxy-nexus")
	echo DEVICE=maguro >> .tmp-config &&
	repo_sync $1
	;;

"nexus-4")
	echo DEVICE=mako >> .tmp-config &&
	repo_sync nexus-4
	;;

"nexus-4-kk")
	echo DEVICE=mako >> .tmp-config &&
	repo_sync nexus-4-kk
	;;

"nexus-5")
	echo DEVICE=hammerhead >> .tmp-config &&
	repo_sync nexus-5
	;;

"nexus-5-l")
	echo DEVICE=hammerhead >> .tmp-config &&
	repo_sync nexus-5-l
	;;

"nexus-s")
	echo DEVICE=crespo >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s-4g")
	echo DEVICE=crespo4g >> .tmp-config &&
	repo_sync $1
	;;

"otoro"|"unagi"|"keon"|"inari"|"hamachi"|"peak"|"helix"|"wasabi"|"flatfish")
	echo DEVICE=$1 >> .tmp-config &&
	repo_sync $1
	;;

"flame"|"flame-kk"|"flame-l")
	echo PRODUCT_NAME=flame >> .tmp-config &&
	repo_sync $1
	;;

"tarako")
	echo DEVICE=sp6821a_gonk >> .tmp-config &&
	echo PRODUCT_NAME=sp6821a_gonk >> .tmp-config &&
	repo_sync $1
	;;

"dolphin")
	echo DEVICE=scx15_sp7715ga >> .tmp-config &&
	echo PRODUCT_NAME=scx15_sp7715gaplus >> .tmp-config &&
	repo_sync $1
	;;

"dolphin-512")
	echo DEVICE=scx15_sp7715ea >> .tmp-config &&
	echo PRODUCT_NAME=scx15_sp7715eaplus >> .tmp-config &&
	repo_sync $1
	;;

"pandaboard")
	echo DEVICE=panda >> .tmp-config &&
	repo_sync $1
	;;

"vixen")
	echo DEVICE=vixen >> .tmp-config &&
	echo PRODUCT_NAME=vixen >> .tmp-config &&
	repo_sync $1
	;;  

"emulator"|"emulator-jb"|"emulator-kk"|"emulator-l")
	echo DEVICE=generic >> .tmp-config &&
	echo LUNCH=full-eng >> .tmp-config &&
	repo_sync $1
	;;

"emulator-x86"|"emulator-x86-jb"|"emulator-x86-kk"|"emulator-x86-l")
	echo DEVICE=generic_x86 >> .tmp-config &&
	echo LUNCH=full_x86-eng >> .tmp-config &&
	repo_sync $1
	;;

"flo")
	echo DEVICE=flo >> .tmp-config &&
	repo_sync $1
	;;

"rpi")
	echo PRODUCT_NAME=rpi >> .tmp-config &&
	repo_sync $1
	;;

"leo-kk"|"leo-l")
	echo PRODUCT_NAME=leo >> .tmp-config &&
	repo_sync $1
	;;

"aries"|"aries-l")
	echo PRODUCT_NAME=aries >> .tmp-config &&
	repo_sync $1
	;;

"scorpion-l")
	echo PRODUCT_NAME=scorpion >> .tmp-config &&
	repo_sync $1
	;;

"sirius-l")
	echo PRODUCT_NAME=sirius >> .tmp-config &&
	repo_sync $1
	;;

*)
	echo "Usage: $0 [-cdflnq] (device name)"
	echo "Flags are passed through to |./repo sync|."
	echo
	echo Valid devices to configure are:
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - nexus-4
	echo - nexus-4-kk
	echo - nexus-5
	echo - nexus-5-l
	echo - nexus-s
	echo - nexus-s-4g
	echo - flo "(Nexus 7 2013)"
	echo - otoro
	echo - unagi
	echo - inari
	echo - keon
	echo - peak
	echo - hamachi
	echo - helix
	echo - tarako
	echo - dolphin
	echo - dolphin-512
	echo - pandaboard
	echo - vixen
	echo - flatfish
	echo - flame
	echo - flame-kk
	echo - flame-l
	echo - rpi "(Revision B)"
	echo - emulator
	echo - emulator-jb
	echo - emulator-kk
	echo - emulator-l
	echo - emulator-x86
	echo - emulator-x86-jb
	echo - emulator-x86-kk
	echo - emulator-x86-l
	echo "> Sony Xperia devices"
	echo - aries "(Z3 Compact KK)"
	echo - aries-l "(Z3 Compact L)"
	echo - leo-kk "(Z3 KK)"
	echo - leo-l "(Z3 L)"
	echo - scorpion-l "(Z3 Tablet Compact L)"
	echo - sirius-l "(Z2 L)"
	exit -1
	;;
esac

if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
