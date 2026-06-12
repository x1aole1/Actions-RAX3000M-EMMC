#!/bin/bash
set -e

#更改默认地址为192.168.6.1
#sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

#更改默认源地址为上海交大源
if [ -f package/emortal/default-settings/files/99-default-settings-chinese ]; then
  sed -i "s,mirrors.vsean.net/openwrt,mirrors.sjtug.sjtu.edu.cn/immortalwrt,g" package/emortal/default-settings/files/99-default-settings-chinese
fi

#添加/修复自定义补丁；24.10 源码树中不存在的旧 21.02 文件会自动跳过
ethinfo_target="$GITHUB_WORKSPACE/openwrt/package/emortal/autocore/files/generic/21_ethinfo.js"
if [ -f "$ethinfo_target" ]; then
  cp -rf "$GITHUB_WORKSPACE/patchs/21_ethinfo.js" "$ethinfo_target"
fi

ca_target="$GITHUB_WORKSPACE/openwrt/package/system/ca-certificates/Makefile"
if [ -f "$ca_target" ]; then
  cp -rf "$GITHUB_WORKSPACE/patchs/ca-Makefile" "$ca_target"
fi

for patch_file in "$GITHUB_WORKSPACE/patchs/iptables-makefile.patch" "$GITHUB_WORKSPACE/patchs/netfilter.patch"; do
  if patch --dry-run -p1 < "$patch_file" >/dev/null 2>&1; then
    patch -p1 < "$patch_file"
  else
    echo "Skip incompatible legacy patch: ${patch_file##*/}"
  fi
done
