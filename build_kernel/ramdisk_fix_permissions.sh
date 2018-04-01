#!/bin/bash
chmod 644 file_contexts
chmod 644 se*
chmod 644 *.rc
chmod 750 init*
chmod 640 fstab*
chmod 644 default.prop
chmod 771 data
chmod 755 dev
chmod 755 lib/modules/*
chmod 755 proc
chmod 755 res
chmod 755 res/*
chmod 755 sbin
chmod 755 sbin/*
cd sbin
chmod 755 su
chmod 664 su/*
chmod 644 *.sh
chmod 644 uci
cd ../
chmod 755 init
chmod 755 sys
chmod 755 system
