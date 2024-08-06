---
title: rust介绍

categories:
- network

tag:
- network

---
# 简介
Rust 是一种系统级编程语言，注重安全性、并发性和性能。它具有内存安全、零成本抽象和保证线程安全等特性。以下是 Rust 基础环境介绍及常见工具：
* 常用站点：
    * https://rustcc.cn/
    * https://rust.p2hp.com/ 
# Rust 安装
通过 Rustup 安装：Rust 官方推荐使用 Rustup 工具来安装 Rust。你可以从 Rust 官方网站 下载并运行 Rustup 安装脚本。

通过包管理器安装：在某些 Linux 发行版中，你也可以通过包管理器来安装 Rust。例如，使用 apt 包管理器可以通过以下命令安装：

```
sudo apt update
sudo apt install rustc cargo
```

# Rust 常见工具
* Cargo： 
    * Cargo 是 Rust 的包管理和构建工具，类似于 npm（Node.js 包管理器）和 Cargo（Python 包管理器）。它能够帮助你创建、构建和管理 Rust 项目，自动下载依赖项，并提供各种构建工具和命令。
* rustc： 
    * rustc 是 Rust 的编译器，用于将 Rust 源代码编译成可执行文件。它可以通过命令行进行调用，也是 Cargo 在后台使用的编译器。
* rustfmt： 
    * rustfmt 是 Rust 的代码格式化工具，用于自动格式化 Rust 代码，使其符合 Rust 社区的代码风格规范。
* clippy：
    * Clippy 是 Rust 的 lint 工具，用于静态代码分析和检查 Rust 代码中潜在的问题和不良实践。它提供了一系列 lint 规则，可以帮助你编写更安全、更健壮的 Rust 代码。

* RLS（Rust Language Server）：
    * RLS 是 Rust 的语言服务器，用于提供 Rust 语言的编辑器支持。它可以与各种编辑器集成，提供自动完成、跳转到定义、重构等功能。
* rustup：
    * rustup 是 Rust 工具链的管理器，用于安装、升级和管理 Rust 工具链（包括 Rust 编译器和 Cargo）。它还可以用于管理多个 Rust 版本的并存和切换。

这些工具都是 Rust 生态系统中常见的工具，可以帮助你进行 Rust 编程并提高开发效率。你可以通过 Cargo 创建一个新的 Rust 项目，并在其中使用这些工具来开发和管理你的项目。

# demo示例

* 步骤 1：安装 Rust 和 Cargo
首先，你需要确保在你的系统上安装了 Rust 和 Cargo。你可以从 Rust 官方网站 下载并运行 Rustup 安装脚本，或者使用系统的包管理器安装 Rust 和 Cargo。

* 步骤 2：创建新的 Rust 项目
使用 Cargo 创建一个新的 Rust 项目。在终端中执行以下命令：

```
cargo new hello_rust
```
这将会在当前目录下创建一个名为 hello_rust 的新目录，并生成一个包含默认项目结构的 Rust 项目。

* 步骤 3：编辑代码

进入 hello_rust 目录，并编辑 src/main.rs 文件。用你喜欢的编辑器打开该文件，并添加以下代码：

```
fn main() {
println!("Hello, Rust!");
}
```
这是一个简单的 Rust 程序，打印出 "Hello, Rust!"。

* 步骤 4：构建和运行程序
返回到项目的根目录，并在终端中执行以下命令来构建和运行程序：

```
cargo run
```
Cargo 将会自动下载依赖并编译项目，并最终运行生成的可执行文件。你应该会在终端中看到输出 "Hello, Rust!"。

* 步骤 5：清理
如果你想清理构建产生的文件，可以执行以下命令：

```
cargo clean
```
这将会删除 target 目录下的所有构建产物。

这就是一个简单的 Rust 示例，演示了如何使用 Cargo 创建一个新的 Rust 项目，并编写一个简单的程序。
你可以根据需要进一步学习 Rust 的语法和功能，以及使用 Cargo 构建更复杂的项目。