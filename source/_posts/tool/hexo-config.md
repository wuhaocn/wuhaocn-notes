---
title: hexo-配置
---
hexo配置详解，包含分类，归档，标题等

```
# Site
title:  #主页标题
subtitle:  #副标题
description: #网站描述description主要用于SEO
keywords:  #博客关键字
author: #作者，左下角显示
language: zh_Hans # 选择中文简体
timezone: 'Asia/Shanghai'  #时区:国内选择上海
# Url
url: http://yoursite.com  #填自己的github pages网址 
root: /                   #网站根目录
permalink: :year/:month/:day/:title/        #文章的 永久链接 格式
permalink_defaults:                         #永久链接中各部分的默认值
pretty_urls:                                #改写 permalink 的值来美化 URL
trailing_index: false # 比如，一个页面的永久链接是 http://example.com/foo/bar/index.html 是否在                         永久链接中保留尾部的 index.html，设置为 false 时去除
trailing_html: true #是否在永久链接中保留尾部.html, 设置为 false 时去除

# Directory
source_dir: source        #资源文件夹，这个文件夹用来存放内容。
public_dir: public        #公共文件夹，这个文件夹用于存放生成的站点文件。
tag_dir: tags             #标签文件夹
archive_dir: archives     #归档文件夹
category_dir: categories  #分类文件夹
code_dir: downloads/code  #Include code 文件夹，source_dir 下的子目录
i18n_dir: :lang           #国际化（i18n）文件夹
skip_render:              #跳过指定文件的渲染。匹配到的文件将会被不做改动地复制到 public 目录中。您可                           使用 glob 表达式来匹配路径。

# Writing
new_post_name: :year-:month-:day-:title.md #生成yyyy-MM-dd-博文名称的名称有助于我们管理自己的博                                               文。 
default_layout: post    #预设布局
titlecase: false  #把标题转换为 title case
external_link:    #在新标签中打开链接
  enable: true #在新标签中打开链接
  field: site #对整个网站（site）生效或仅对文章（post）生效
  exclude: ''  #需要排除的域名。主域名和子域名如 www 需分别配置
filename_case: 0  #把文件名称转换为 (1) 小写或 (2) 大写
render_drafts: false #显示草稿
post_asset_folder: false  #启动 Asset 文件夹 new 文件的同时，xxxx.md文件还有一个同名的文件夹
relative_link: false  #把链接改为与根目录的相对位址
future: true  #显示未来的文章
highlight:
  enable: true  #开启代码块高亮
  line_number: true  #显示行数
  auto_detect: false  #如果未指定语言，则启用自动检测
  tab_replace: ''  #用 n 个空格替换 tabs；如果值为空，则不会替换 tabs
  wrap: true    # 将代码块包装到<table>
  hljs: false   # CSS类使用hljs-*前缀

# Home page setting
# path: Root path for your blogs index page. (default = '')
# per_page: Posts displayed per page. (0 = disable pagination)
# order_by: Posts order. (Order by date descending by default)
index_generator:
  path: ''
  per_page: 10
  order_by: -date

# Category & Tag
default_category: uncategorized  #默认分类
category_map:   #分类别名
tag_map:   #标签别名

# Metadata elements
meta_generator: true   # Meta generator 标签。 值为 false 时 Hexo 不会在头部插入该标签

# Date / Time format
## Hexo uses Moment.js to parse and display date Hexo 使用 Moment.js 来解析和显示时间
## You can customize the date format as defined in
## http://momentjs.com/docs/#/displaying/format/
date_format: YYYY-MM-DD  #日期格式
time_format: HH:mm:ss   #时间格式
use_date_for_updated: false  #启用以后，如果Front Matter中没有指定 updated， post.updated 将会使用date的值而不是文件的创建时间。在Git工作流中这个选项会很有用

# Pagination
## Set per_page to 0 to disable pagination
per_page: 10  #每页显示的文章量 (0 = 关闭分页功能)
pagination_dir: page  #分页目录

# Include / Exclude file(s)
## include:/exclude: options only apply to the 'source/' folder
include:  #Hexo 默认会忽略隐藏文件和文件夹（包括名称以下划线和 . 开头的文件和文件夹，Hexo 的 _posts 和            _data 等目录除外）。通过设置此字段将使 Hexo 处理他们并将它们复制到 source 目录下。
exclude:  #Hexo 会忽略这些文件和目录
ignore:   #Ignore files/folders

# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: icarus #当前主题名称。值为false时禁用主题

# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:   #部署部分的设置
  type: git
  repo: https://github.com/CodePandaes/CodePandaes.github.io.git #github中仓库地址
  branch: master
```