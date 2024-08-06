
---
title: eBPF简介

categories:
- ebpf

tag:
- ebpf

---
## eBPF简介
eBPF是Linux内核的一个子系统，它允许用户编写、运行、调试、更新程序，这些程序运行在内核的环境中，
可以访问内核的数据结构，从而实现内核功能的增强和扩展。
## 基础设施
- linux kernel
- llvm compiler
- gcc compiler
- bpftool
## eBPF常见库
- c++
    - libbpf
- go
    - eBPF
    - libbpfgo
- rust
    - libbpf-rs
    - aya
### hello world

```c
SEC("tp/syscalls/sys_enter_write")
int handle_tp(void *ctx)
{
	pid_t pid = bpf_get_current_pid_tgid() >> 32;
	if (pid_filter && pid != pid_filter)
		return 0;
	bpf_printk("BPF triggered sys_enter_write from PID %d.\n", pid);
	return 0;
}

```
这段代码是一个使用eBPF（extended Berkeley Packet Filter）的内核钩子程序，用于在系统调用"write"被调用时进行处理。让我逐步解释一下：

* SEC("tp/syscalls/sys_enter_write"): 这是一个eBPF程序的关键字，它指定了程序应该连接到的内核钩子点，即在系统调用"write"进入内核时执行。

* int handle_tp(void *ctx): 这是eBPF程序的入口函数，它接收一个上下文参数ctx，但在这段代码中没有使用。

* pid_t pid = bpf_get_current_pid_tgid() >> 32;: 这一行代码获取当前进程的PID（进程ID）。bpf_get_current_pid_tgid()函数返回一个64位的值，其中高32位包含PID，低32位包含TID（线程ID）。通过右移32位来获取PID。

* if (pid_filter && pid != pid_filter) return 0;: 这行代码检查是否设置了PID过滤器，并且当前进程的PID是否与过滤器中指定的PID相符。如果设置了PID过滤器且PID不匹配，则直接返回0，即不执行后续的处理逻辑。

* bpf_printk("BPF triggered sys_enter_write from PID %d.\n", pid);: 这行代码打印一条日志消息，指示eBPF程序已经被触发，并显示了触发程序的PID。

* return 0;: 最后，函数返回0，表示成功执行。

综上所述，这段代码的作用是在系统调用"write"被调用时触发，然后检查当前进程的PID是否符合过滤条件，如果符合则打印日志消息。

