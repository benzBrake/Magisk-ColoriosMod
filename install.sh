##########################################################################################
#
# Magisk模块安装脚本
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. 将文件放入 system 夹(并删除 placeholder 文件)
# 2. 在 module.prop 中填写您的模块信息
# 3. 在此文件中配置和调整
# 4. 果需要开机执行脚本，请将其添加到 common/post-fs-data.sh 或者 common/service.sh
# 5. 将其他或修改的系统属性添加到 common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# 替换列表
##########################################################################################

# 列出你想在系统中直接替换的所有目录
# 查看文档，了解更多关于 Magic Mount 如何工作的信息，以及你为什么需要它

# 按照以下格式构建列表
# 这是一个示例
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# 按照以下格式构建列表
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# 可用变量 :
#
# MAGISK_VER (string): 当前 Magisk 版本
# MAGISK_VER_CODE (int): 当前 Magisk 版本代码
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "   ColorOS 11/RUI 2.0 优化      "
  ui_print "   https://kkp.disk.st         "
  ui_print "   1.强制90HZ                   "
  ui_print "   2.应用分身增强                "
  ui_print "   3.禁用自动更新                "
  ui_print "   4.去温控                     "
  ui_print "   5.增加多任务锁定数量           "
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- 解压模块文件"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  ui_print "- 设置权限"
  set_perm_recursive $MODPATH/tools
  ui_print "- 配置中 .."
  work_dir=/sdcard/Android/CMod
  if [ ! -d $work_dir ]; then
    mkdir -p $work_dir
  fi
  rm -rf $work_dir/settings.ini
  if [ ! -e $work_dir/settings.ini ]; then
    touch $work_dir/settings.ini
    ui_print "- 开机时强制90HZ/120HZ？"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      echo "lock_fresh_rate=true" >> $work_dir/settings.ini
    else
      ui_print "- 已选择[否]"
      echo "lock_fresh_rate=false" >> $work_dir/settings.ini
    fi
    ui_print "- 是否开机时禁用自动更新？"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      echo "disable_upgrade=true" >> $work_dir/settings.ini
    else
      echo "disable_upgrade=false" >> $work_dir/settings.ini
    fi
    ui_print "- 开机时自动禁用温控？"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      echo "disable_monitor=true" >> $work_dir/settings.ini
    else
      ui_print "- 已选择[否]"
      echo "disable_monitor=false" >> $work_dir/settings.ini
    fi
    ui_print "- 开机时自动禁用无用的安全组件（安全支付，安全键盘）？"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      echo "disable_security=true" >> $work_dir/settings.ini
    else
      ui_print "- 已选择[否]"
      echo "disable_security=false" >> $work_dir/settings.ini
    fi
    ui_print "- 开机时自动禁用游戏空间？"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      echo "disable_gamespace=true" >> $work_dir/settings.ini
    else
      ui_print "- 已选择[否]"
      echo "disable_gamespace=false" >> $work_dir/settings.ini
    fi
    ui_print "- 开机时自动禁用遥测（数据收集）?"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      echo "disable_disable_telemery=true" >> $work_dir/settings.ini
    else
      ui_print "- 已选择[否]"
      echo "disable_disable_telemery=false" >> $work_dir/settings.ini
    fi
    ui_print "- 解除多任务锁定数量限制"
    ui_print "  音量+ = 是"
    ui_print "  音量– = 否"
    if chooseport; then
      ui_print "- 已选择[是]"
      sed -i 's@value="5"@value="100"@' /data/user_de/0/com.oppo.launcher/shared_prefs/Configuration.xml
    else
      ui_print "- 已选择[否]"
    fi
    
    if [ -d /data/data/com.coolapk.market ]; then
      ui_print " "
      ui_print "- 检测到你安装了酷安"
      ui_print "- 即将跳转到开发者主页(可选)"
      ui_print "  音量+ = 吼呀"
      ui_print "  音量– = 不吼"
      if chooseport; then
        ui_print "正在跳转....."
        am start -d 'coolmarket://u/394173' >/dev/null 2>&1
      fi
    fi
  fi
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
}

chooseport_legacy() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    timeout 0 $MODPATH/tools/$ARCH32/keycheck
    timeout $delay $MODPATH/tools/$ARCH32/keycheck
    local sel=$?
    if [ $sel -eq 42 ]; then
      return 0
    elif [ $sel -eq 41 ]; then
      return 1
    elif $error; then
      abort "未检测到音量键!"
    else
      error=true
      echo "- 未检测到音量键。再试一次。"
    fi
  done
}

chooseport() {
  # Original idea by chainfire and ianmacd @xda-developers
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false 
  while true; do
    local count=0
    while true; do
      timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
      sleep 0.5; count=$((count + 1))
      if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
        return 0
      elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
        return 1
      fi
      [ $count -gt 15 ] && break
    done
    if $error; then
      # abort "未检测到音量键!"
      echo "未检测到音量键。 尝试 keycheck 模式"
      export chooseport=chooseport_legacy VKSEL=chooseport_legacy
      chooseport_legacy $delay
      return $?
    else
      error=true
      echo "- 未检测到音量键。再试一次。"
    fi
  done
}