# location  
    /etc/systemd/user.conf

```bash
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it under the
#  terms of the GNU Lesser General Public License as published by the Free
#  Software Foundation; either version 2.1 of the License, or (at your option)
#  any later version.
#
# Entries in this file show the compile time defaults. Local configuration
# should be created by either modifying this file (or a copy of it placed in
# /etc/ if the original file is shipped in /usr/), or by creating "drop-ins" in
# the /etc/systemd/user.conf.d/ directory. The latter is generally recommended.
# Defaults can be restored by simply deleting the main configuration file and
# all drop-ins located in /etc/.
#
# Use 'systemd-analyze cat-config systemd/user.conf' to display the full config.
#
# See systemd-user.conf(5) for details.

[Manager]
#LogLevel=info
#LogTarget=auto
#LogColor=yes
#LogLocation=no
#LogTime=no
#SystemCallArchitectures=
#TimerSlackNSec=
#StatusUnitFormat=description
#DefaultTimerAccuracySec=1min
#DefaultStandardOutput=inherit
#DefaultStandardError=inherit
DefaultTimeoutStartSec=15s
DefaultTimeoutStopSec=10s
#DefaultTimeoutAbortSec=
#DefaultDeviceTimeoutSec=90s
DefaultRestartSec=1000ms
#DefaultStartLimitIntervalSec=10s
DefaultStartLimitBurst=10
#DefaultEnvironment=
#DefaultLimitCPU=
#DefaultLimitFSIZE=
#DefaultLimitDATA=
#DefaultLimitSTACK=
#DefaultLimitCORE=
#DefaultLimitRSS=
#DefaultLimitNOFILE=
#DefaultLimitAS=
#DefaultLimitNPROC=
#DefaultLimitMEMLOCK=
#DefaultLimitLOCKS=
#DefaultLimitSIGPENDING=
#DefaultLimitMSGQUEUE=
#DefaultLimitNICE=
#DefaultLimitRTPRIO=
#DefaultLimitRTTIME=
#DefaultMemoryPressureThresholdSec=200ms
#DefaultMemoryPressureWatch=auto
#DefaultSmackProcessLabel=
#ReloadLimitIntervalSec=
#ReloadLimitBurst
DefaultLimitNOFILE=1024:1048576

```

# Location
    /etc/systemd/system.conf

```bash
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it under the
#  terms of the GNU Lesser General Public License as published by the Free
#  Software Foundation; either version 2.1 of the License, or (at your option)
#  any later version.
#
# Entries in this file show the compile time defaults. Local configuration
# should be created by either modifying this file, or by creating "drop-ins" in
# the system.conf.d/ subdirectory. The latter is generally recommended.
# Defaults can be restored by simply deleting this file and all drop-ins.
#
# Use 'systemd-analyze cat-config systemd/system.conf' to display the full config.
#
# See systemd-system.conf(5) for details.

[Manager]
#LogLevel=info
#LogTarget=journal-or-kmsg
#LogColor=yes
#LogLocation=no
#LogTime=no
#DumpCore=yes
#ShowStatus=yes
#CrashChangeVT=no
#CrashShell=no
#CrashReboot=no
#CtrlAltDelBurstAction=reboot-force
#CPUAffinity=
#NUMAPolicy=default
#NUMAMask=
#RuntimeWatchdogSec=0
#RebootWatchdogSec=10min
#KExecWatchdogSec=0
#WatchdogDevice=
#CapabilityBoundingSet=
#NoNewPrivileges=no
#SystemCallArchitectures=
#TimerSlackNSec=
#StatusUnitFormat=description
#DefaultTimerAccuracySec=1min
#DefaultStandardOutput=journal
#DefaultStandardError=inherit
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=5s
#DefaultTimeoutAbortSec=
#DefaultRestartSec=100ms
#DefaultStartLimitIntervalSec=10s
#DefaultStartLimitBurst=5
#DefaultEnvironment=
#DefaultCPUAccounting=no
#DefaultIOAccounting=no
#DefaultIPAccounting=no
#DefaultBlockIOAccounting=no
#DefaultMemoryAccounting=yes
#DefaultTasksAccounting=yes
#DefaultTasksMax=15%
#DefaultLimitCPU=
#DefaultLimitFSIZE=
#DefaultLimitDATA=
#DefaultLimitSTACK=
#DefaultLimitCORE=
#DefaultLimitRSS=
#DefaultLimitNOFILE=1024:524288
DefaultLimitNOFILE=1024:1048576
#DefaultLimitAS=
#DefaultLimitNPROC=
#DefaultLimitMEMLOCK=
#DefaultLimitLOCKS=
#DefaultLimitSIGPENDING=
#DefaultLimitMSGQUEUE=
#DefaultLimitNICE=
#DefaultLimitRTPRIO=
#DefaultLimitRTTIME=
#DefaultOOMPolicy=stop

```