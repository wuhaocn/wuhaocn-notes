
---
title: eBPF开发环境

categories:
- ebpf

tag:
- ebpf

---

## env
* 共享文件夹
sudo apt-get install open-vm-tools
* ssh
sudo apt-get update
sudo apt-get install openssh-server

* vim
sudo apt-get install vim
* nettool
sudo  apt-get install net-tools iproute2
* 编译工具
sudo  apt-get install build-essential cmake golang-go

sudo  apt install libncurses5-dev flex bison libelf-dev binutils-dev libssl-dev
sudo  apt-get install clang llvm
sudo  apt install binutils-dev libelf-dev libcap-dev

sudo apt-get install bpfcc-tools linux-headers-$(uname -r)
sudo apt-get install -y bpftrace

sudo apt install -y bison build-essential cmake flex git libedit-dev libllvm13 llvm-13-dev libclang-13-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils

sudo apt-get -y install luajit luajit-5.1-dev #非必需的
