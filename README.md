* 1.hexo-cli
npm install -g hexo-cli
npm install hexo
npm init notes

cd blog
* 2.hexo-deployer-git
npm install hexo-deployer-git --save
```
deploy:
  type: git
  repo: https://github.com/wuhaocn/wuhaocn.github.io
  branch: main
```
* 3.hexodeploy

```
npm install

```
hexo clean && hexo deploy
* 参考主题
```
git clone https://github.com/cofess/hexo-theme-pure.git themes/pure

npm install hexo-wordcount --save

npm install hexo-generator-json-content --save

npm install hexo-generator-feed --save

npm install hexo-generator-sitemap --save

npm install hexo-generator-baidu-sitemap --save

npm cache verify 
```