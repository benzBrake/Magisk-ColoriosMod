#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

sleep 15

pm disable com.coloros.bootreg
pm disable com.android.stk
pm disable com.coloros.childrenspace
pm disable com.iflytek.speechsuite
pm disable com.coloros.remoteguardservice
pm disable com.coloros.healthcheck
pm disable com.coloros.healthservice
pm disable com.coloros.operationManual
# pm disable com.coloros.deepthinker
pm disable com.oppo.bttestmode
pm disable com.oppo.wifitest
pm disable com.oppo.nhs
pm disable com.google.ar.core
pm disable com.google.android.accessibility.soundamplifier
# Disable Ads
pm disable com.opos.ads
. /sdcard/Android/CMod/settings.ini
if [ $lock_fresh_rate = "true" ]; then
  su -c service call SurfaceFlinger 1035 i32 1
fi
if [ $disable_upgrade = "true" ]; then
  pm disable com.coloros.sau
  pm disable com.coloros.sauhelper
  pm disable com.oppo.ota
else
  pm enable com.coloros.sau
  pm enable com.coloros.sauhelper
  pm enable com.oppo.ota
fi
if [ $disable_monitor = "true" ]; then
  pm disable com.oppo.oppopowermonitor
  pm disable com.coloros.oppoguardelf/com.coloros.powermanager.fuelgaue.GuardElfAIDLService
  pm disable com.coloros.oppoguardelf/com.coloros.oppoguardelf.OplusGuardElfService
  setprop sys.hans.enable 0
  setprop persist.vendor.enable.hans 0
else
  pm enable com.oppo.oppopowermonitor
  pm enable com.coloros.oppoguardelf/com.coloros.powermanager.fuelgaue.GuardElfAIDLService
  pm enable com.coloros.oppoguardelf/com.coloros.oppoguardelf.OplusGuardElfService
fi
if [ $disable_security = "true" ]; then
  pm disable com.coloros.codebook
  pm disable com.coloros.securepay
  pm disable com.coloros.securitykeyboard
  pm disable com.coloros.securityguard
else
  pm enable com.coloros.codebook
  pm enable com.coloros.securepay
  pm enable com.coloros.securitykeyboard
  pm enable com.coloros.securityguard
fi
if [ $disable_gamespace = "true" ]; then
  pm disable com.coloros.gamespace
  pm disable com.coloros.gamespaceui
else
  pm enable com.coloros.gamespace
  pm enable com.coloros.gamespaceui
fi
if [ $disable_telemery = "true" ]; then
  pm disable com.nearme.statistics.rom
  pm disable com.oplus.onetrace
  pm disable com.oplus.crashbox
  pm disable com.oplus.postmanservice
  pm disable com.heytap.habit.analysis
  pm disable com.google.mainline.telemetry
  pm disable com.coloros.logkit
else
  pm enable com.nearme.statistics.rom
  pm enable com.oplus.onetrace
  pm enable com.oplus.crashbox
  pm enable com.oplus.postmanservice
  pm enable com.heytap.habit.analysis
  pm enable com.google.mainline.telemetry
  pm enable com.coloros.logkit
fi