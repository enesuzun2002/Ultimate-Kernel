#!/system/bin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Written by @enesuzun2002
# Got some help from my friend @ananjaser1211
#
LOGFILE=/data/hyper_log/hyper_log.log

log_print() {
  echo "$1"
  echo "$1" >> $LOGFILE
}

if [ ! -e /data/hyper_log ]; then
	mkdir -p /data/hyper_log
	chown -R root root /data/hyper_log
	chmod -R 755 /data/hyper_log
	log_print "-- Created Log Folder"
fi

if [ -e /data/hyper_log/hyper_logcat.log ]; then
  log_print "-- Renaming old logcat with date and time"
  mv "/data/hyper_log/hyper_logcat.log" "/data/hyper_log/hyper_logcat_$(date +"%d-%m-%Y %H:%M:%S").log"
fi

if [ -e /data/hyper_log/hyper_last_kmsg.log ]; then
  log_print "-- Renaming old last_kmsg with date and time"
  mv "/data/hyper_log/hyper_last_kmsg.log" "/data/hyper_log/hyper_last_kmsg_$(date +"%d-%m-%Y %H:%M:%S").log"
fi

# Hyper-Logs
log_print "-- Creating Logs"
cp "/proc/last_kmsg" "/data/hyper_log/hyper_last_kmsg.log"
logcat > /data/hyper_log/hyper_logcat.log
log_print "-- Script Successfull"
