* 1.hexo-cli
npm install -g hexo-cli
npm init blog
npm install hexo
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
