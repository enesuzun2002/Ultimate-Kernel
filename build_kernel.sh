#!/bin/bash

###############################################################################
# To all DEV around the world :)                                              #
# to build this kernel you need to be ROOT and to have bash as script loader  #
# do this:                                                                    #
# cd /bin                                                                     #
# rm -f sh                                                                    #
# ln -s bash sh                                                               #
#                                                                             #
# Now you can build my kernel.                                                #
# using bash will make your life easy. so it's best that way.                 #
# Have fun and update me if something nice can be added to my source.	      #
#                                                         		      #
# Original scripts by halaszk & various sources throughout gitHub             #
# modified by UpInTheAir for SkyHigh kernels				      #
# very very slightly modified by The Sickness for his Twisted S6 kernel       #
#                                                         		      #
###############################################################################


############################################ SETUP ############################################

# Time of build startup
res1=$(date +%s.%N)
#################################### OPTIONAL SOURCE CLEAN ####################################
echo
echo "${bldcya}***** Setting up Environment *****${txtrst}";
echo
. ./env_setup.sh ${1} || exit 1;

if [ ! -f $KERNELDIR/.config ]; then
	echo
	echo "${bldcya}***** Writing Config *****${txtrst}";
	cp $KERNELDIR/arch/arm64/configs/$KERNEL_CONFIG .config;
	make ARCH=arm64 $KERNEL_CONFIG;
fi;

. $KERNELDIR/.config


########################################### CLEAN UP ##########################################

echo
echo "${bldcya}***** Clean up first *****${txtrst}"

find . -type f -name "*~" -exec rm -f {} \;
find . -type f -name "*orig" -exec rm -f {} \;
find . -type f -name "*rej" -exec rm -f {} \;

# cleanup previous Image files
if [ -e $KERNELDIR/dt.img ]; then
	rm $KERNELDIR/dt.img;

fi;
if [ -e $KERNELDIR/arch/arm64/boot/Image ]; then
	rm $KERNELDIR/arch/arm64/boot/Image;
fi;
if [ -e $KERNELDIR/arch/arm64/boot/dt.img ]; then
	rm $KERNELDIR/arch/arm64/boot/dt.img;
fi;

# cleanup variant ramdisk files
find . -type f -name "EMPTY_DIRECTORY" -exec rm -f {} \;

if [ -e $BK/$TARGET/boot.img ]; then
	rm -rf $BK/$TARGET/boot.img
fi;
if [ -e $BK/$TARGET/Image ]; then
	rm -rf $BK/$TARGET/Image
fi;
if [ -e $BK/$TARGET/ramdisk.gz ]; then
	rm -rf $BK/$TARGET/ramdisk.gz
fi;

cd ${KERNELDIR}

# cleanup old output files
rm -rf ${KERNELDIR}/output/$TARGET/*

# cleanup old dtb files
rm -rf $KERNELDIR/arch/arm64/boot/dts/*.dtb;

echo "Done"


####################################### COMPILE IMAGES #######################################

echo
echo "${bldcya}***** Compiling kernel *****${txtrst}"

if [ $USER != "root" ]; then
	make CONFIG_DEBUG_SECTION_MISMATCH=y -j10 Image ARCH=arm64
else
	make -j10 Image ARCH=arm64
fi;

make dtbs

if [ -e $KERNELDIR/arch/arm64/boot/Image ]; then
	echo
	echo "${bldcya}***** Final Touch for Kernel *****${txtrst}"
	stat $KERNELDIR/arch/arm64/boot/Image || exit 1;
	mv ./arch/arm64/boot/Image ./$BK/$TARGET
	echo
	echo "--- Creating custom dt.img ---"
	./scripts/dtbTool/dtbTool -o dt.img -s 2048 -d ./arch/arm64/boot/dts/
else
	echo "${bldred}Kernel STUCK in BUILD!${txtrst}"
	exit 0;
fi;

echo
echo "Done"


###################################### RAMDISK GENERATION #####################################

echo
echo "${bldcya}***** Make ramdisk *****${txtrst}"
# fix ramdisk permissions
cd ${KERNELDIR}/$BK
cp ./ramdisk_fix_permissions.sh ./$TARGET/ramdisk/ramdisk_fix_permissions.sh
cd ${KERNELDIR}/$BK/$TARGET/ramdisk
chmod 0777 ramdisk_fix_permissions.sh
./ramdisk_fix_permissions.sh 2>/dev/null
rm -f ramdisk_fix_permissions.sh

# make ramdisk
cd ${KERNELDIR}/$BK
./mkbootfs ./$TARGET/ramdisk | gzip > ./$TARGET/ramdisk.gz

echo
echo "Done"


##################################### BOOT.IMG GENERATION #####################################

echo
echo "${bldcya}***** Make boot.img *****${txtrst}"

read -p "Do you want to use a stock (s) or custom generated (c) dt.img? (s/c) > " dt
echo
if [ "$dt" = "c" -o "$dt" = "C" ]; then
./mkbootimg --kernel ./$TARGET/Image --dt ${KERNELDIR}/dt.img --ramdisk ./$TARGET/ramdisk.gz --base 0x10000000 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 -o ./$TARGET/boot.img
fi
if [ "$dt" = "s" -o "$dt" = "S" ]; then
./mkbootimg --kernel ./$TARGET/Image --dt ./$TARGET/dt.img --ramdisk ./$TARGET/ramdisk.gz --base 0x10000000 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 -o ./$TARGET/boot.img
fi

echo -n "SEANDROIDENFORCE" >> ./$TARGET/boot.img

echo "Done"


###################################### ARCHIVE GENERATION #####################################

echo
echo "${bldcya}***** Make archives *****${txtrst}"

cp -R ./enes ${KERNELDIR}/output/$TARGET/
cp ./$TARGET/boot.img ${KERNELDIR}/output/$TARGET/enes
cp -R ./system ${KERNELDIR}/output/$TARGET/
cp -R ./META-INF ${KERNELDIR}/output/$TARGET/

cd ${KERNELDIR}/output/$TARGET
GETVER=`grep 'S6_MM_*v' ${KERNELDIR}/.config | sed 's/.*".//g' | sed 's/-S.*//g'`

# Without Clearwater audio mod
AUDIO=`grep '# CONFIG_SND_SOC_ARIZONA_CONTROL*' ${KERNELDIR}/.config | sed 's/.*".//g' | sed 's/-S.*//g'`
if [ "$AUDIO" == "# CONFIG_SND_SOC_ARIZONA_CONTROL is not set" ]; then
	AUDIO="no-audio"
else
	AUDIO=""
fi

zip -r Ultimate-Kernel-$TARGET-7.0-Beta.zip .
tar -H ustar -c ${KERNELDIR}/output/$TARGET/enes/boot.img > Ultimate-Kernel-$TARGET-7.0-Beta.tar
md5sum -t Ultimate-Kernel-$TARGET-7.0-Beta.tar >> Ultimate-Kernel-$TARGET-7.0-Beta.tar
mv Ultimate-Kernel-$TARGET-7.0-Beta.tar Ultimate-Kernel-$TARGET-7.0-Beta.tar.md5

echo
echo "Done"


#################################### OPTIONAL SOURCE CLEAN ####################################

echo
echo "${bldcya}***** Clean source *****${txtrst}"

cd ${KERNELDIR}
read -p "Do you want to Clean the source? (y/n) > " mc
if [ "$mc" = "Y" -o "$mc" = "y" ]; then
	xterm -e make clean
	xterm -e make mrproper
fi

echo
echo "Build completed"
echo
echo "${txtbld}***** Flashable zip found in output directory *****${txtrst}"
echo
# build script ends
