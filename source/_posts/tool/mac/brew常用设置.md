---
title: brew常用设置

categories:
- devops

tag:
- brew
---

## 1.brew更新or安装慢

* 更新ustc.edu源并设置强制更新

```

cd $(brew --repo)
 
git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
 
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
 
git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

export HOMEBREW_FORCE_BREWED_GIT="1"

```
* 更新github源并设置强制更新

```
建议配置ssh快一些
cd $(brew --repo)
git clone 
git remote set-url origin git@github.com:Homebrew/brew.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin git@github.com:Homebrew/homebrew-core.git
export HOMEBREW_FORCE_BREWED_GIT="1"
```


## 2.brew重启安装

```
1、卸载

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
2、安装【卸载与安装差别只有最后的install和undeinstall】

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
3、更新

brew update
 

遇到问题：

1、raw.githubusercontent.com 链接不到或者访问太慢

解决：绑定host

199.232.28.133 raw.githubusercontent.com
有host修改软件，直接在软件修改即可

没有的按照如下方式修改追加

sudo vim /etc/hosts
在hosts文件最后追加如下，保存退出即可：

199.232.28.133 raw.githubusercontent.com
```

## 3.常见命令

```
安装软件：brew install 软件名，例：brew install wget

搜索软件：brew search 软件名，例：brew search wget

卸载软件：brew uninstall 软件名，例：brew uninstall wget

更新所有软件：brew update

更新具体软件：brew upgrade 软件名 ，例：brew upgrade git

显示已安装软件：brew list

查看软件信息：brew info／home 软件名 ，例：brew info git ／ brew home git

显示包依赖：brew reps

显示安装的服务：brew services list

安装服务启动、停止、重启：brew services start/stop/restart serverName

```

## 全部替换国内源

```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```