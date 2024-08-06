
---
title: git常见设置

categories:
- git

tag:
- git

---
## 用户名和邮箱

## 查看配置
```
# 查看全局配置
git config --global --get user.name
git config --global --get user.email

# 查看仓库配置
git config --get user.name
git config --get user.email

```

## 全局
```
# 设置全局用户名
git config --global user.name "Your Name"

# 设置全局邮箱
git config --global user.email "your.email@example.com"

```

## 项目级
```
# 设置仓库用户名
git config user.name "Your Repo Name"

# 设置仓库邮箱
git config user.email "your.repo.email@example.com"

```