## 1.hexo-cli

npm install -g hexo-cli
npm install hexo
npm init notes
cd notes

## 2.hexo-deployer-git
npm install hexo-deployer-git --save
```
deploy:
  type: git
  repo: https://github.com/wuhaocn/wuhaocn.github.io
  branch: main
```
## 3.hexodeploy

```
npm install

```
hexo clean && hexo deploy
## 4.hexo-theme-pure
```
git clone https://github.com/cofess/hexo-theme-pure.git themes/pure

npm install hexo-wordcount --save

npm install hexo-generator-json-content --save

npm install hexo-generator-feed --save

npm install hexo-generator-sitemap --save

npm install hexo-generator-baidu-sitemap --save

npm cache verify 
```
## 5.hexo-theme-icarus主题
```
https://github.com/ppoffice/hexo-theme-icarus
npm install hexo-theme-icarus
npm install --save bulma-stylus@0.8.0 hexo-renderer-inferno@^0.1.3
hexo config theme icarus

```


```
This package has installed:
	•	Node.js v16.5.0 to /usr/local/bin/node
	•	npm v7.19.1 to /usr/local/bin/npm
Make sure that /usr/local/bin is in your $PATH.

npm config set registry https://registry.npm.taobao.org 

npm config get registry 

```