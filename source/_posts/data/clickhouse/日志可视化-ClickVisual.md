
## 目录

- **快速开始**
   - [2022 Roadmap](https://clickvisual.gocn.vip/clickvisual/01quickstart/roadmap.html)
   - [什么是 ClickVisual](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html)
      - [特性](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E7%89%B9%E6%80%A7)
      - [技术架构](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E6%8A%80%E6%9C%AF%E6%9E%B6%E6%9E%84)
      - [ClickVisual 使用效果](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#clickvisual-%E4%BD%BF%E7%94%A8%E6%95%88%E6%9E%9C)
         - [日志查询](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E6%97%A5%E5%BF%97%E6%9F%A5%E8%AF%A2)
         - [可视化配置](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E5%8F%AF%E8%A7%86%E5%8C%96%E9%85%8D%E7%BD%AE)
         - [增加告警规则](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E5%A2%9E%E5%8A%A0%E5%91%8A%E8%AD%A6%E8%A7%84%E5%88%99)
         - [查看历史告警](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E6%9F%A5%E7%9C%8B%E5%8E%86%E5%8F%B2%E5%91%8A%E8%AD%A6)
         - [场景支持](https://clickvisual.gocn.vip/clickvisual/01quickstart/what-is-the-clickvisual.html#%E5%9C%BA%E6%99%AF%E6%94%AF%E6%8C%81)
   - [快速上手](https://clickvisual.gocn.vip/clickvisual/01quickstart/quick-learning.html)
   - [使用 Docker-Compose 体验 ClickVisual](https://clickvisual.gocn.vip/clickvisual/01quickstart/experience-clickvisual-with-docker-compose.html)
   - [Q&A](https://clickvisual.gocn.vip/clickvisual/01quickstart/qa.html)
- **代码贡献**
   - [开发环境构建](https://clickvisual.gocn.vip/clickvisual/06join/env.html)
   - [如何参与代码贡献](https://clickvisual.gocn.vip/clickvisual/06join/pr.html)
   - [新增告警推送途径](https://clickvisual.gocn.vip/clickvisual/06join/alert-push-channel.html)
- **应用安装**
   - [安装介绍](https://clickvisual.gocn.vip/clickvisual/02install/install-introduce.html)
   - [安装基本要求](https://clickvisual.gocn.vip/clickvisual/02install/install-require.html)
   - [二进制安装](https://clickvisual.gocn.vip/clickvisual/02install/binary-installation.html)
   - [Docker 安装](https://clickvisual.gocn.vip/clickvisual/02install/docker-installation.html)
   - [Kubernetes 集群安装](https://clickvisual.gocn.vip/clickvisual/02install/k8s-installation.html)
- **功能介绍**
   - [使用说明](https://clickvisual.gocn.vip/clickvisual/03funcintro/instructions.html)
   - [系统设置](https://clickvisual.gocn.vip/clickvisual/03funcintro/system-settings.html)
   - [子路径配置](https://clickvisual.gocn.vip/clickvisual/03funcintro/subpath-configuration.html)
   - [集群模式使用](https://clickvisual.gocn.vip/clickvisual/03funcintro/cluster-mode.html)
   - [已有数据表接入](https://clickvisual.gocn.vip/clickvisual/03funcintro/access-existing-tables.html)
   - [ClickHouse 常用 SQL](https://clickvisual.gocn.vip/clickvisual/03funcintro/clickHouse-commonly-used-sql.html)
   - [Fluent-bit 配置参考](https://clickvisual.gocn.vip/clickvisual/03funcintro/fluent-bit-configuration-reference.html)
   - [告警功能配置说明](https://clickvisual.gocn.vip/clickvisual/03funcintro/alarm-function-configuration-description.html)
   - [ClickVisual 配置说明](https://clickvisual.gocn.vip/clickvisual/03funcintro/clickvisual-configuration-description.html)
   - [模板生成](https://clickvisual.gocn.vip/clickvisual/03funcintro/template-gen.html)
- **应用授权**
   - [授权介绍](https://clickvisual.gocn.vip/clickvisual/04appauth/auth-intro.html)
   - [ClickVisual Auth](https://clickvisual.gocn.vip/clickvisual/04appauth/clickvisual-auth.html)
   - [Auth Proxy](https://clickvisual.gocn.vip/clickvisual/04appauth/auth-proxy.html)
   - [GitLab Oauth2](https://clickvisual.gocn.vip/clickvisual/04appauth/gitlab-oauth2.html)
   - [GitHub Oauth2](https://clickvisual.gocn.vip/clickvisual/04appauth/github-oauth2.html)
- **架构原理**
   - [石墨文档日志架构](https://clickvisual.gocn.vip/clickvisual/05arch/graphite-document-logging-architecture.html)
## 概述
ClickVisual 是一个轻量级的开源日志查询、分析、报警的可视化平台，致力于提供一站式应用可靠性的可视化的解决方案。既可以独立部署使用，也可作为插件集成到第三方系统。目前是市面上唯一一款支持 ClickHouse 的类 Kibana 的业务日志查询平台。
## 特性

- 支持可视化的查询面板，可查询命中条数直方图和原始日志。
- 支持设置日志索引功能，分析不同索引的占比情况。
- 支持可视化的 VS Code 风格配置中心，能够便捷地将 logagent 配置同步到 Kubernetes 集群 ConfigMap 中。
- 支持 GitHub 和 GitLab 授权登录。
- 支持 Proxy Auth 功能，能被被非常轻松的集成到第三方系统。
- 支持物理机、Docker、Kubernetes 部署。
- 支持基于 ClicHouse 日志的实时报警功能。
## 技术架构
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1657079559717-8215af8f-e42f-4b83-bf97-1acc7732b7c5.png#clientId=u3f932fa8-b09c-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=uede22213&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1104&originWidth=1552&originalType=url&ratio=1&rotation=0&showTitle=false&size=305332&status=done&style=none&taskId=u7a5d97d9-bc03-4dd5-b129-5267de24822&title=)
## ClickVisual 使用效果
### 日志查询
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1657079559903-1f618d51-8188-4caa-8b70-9ba40301b948.png#clientId=u3f932fa8-b09c-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u0a01f2d5&margin=%5Bobject%20Object%5D&name=image.png&originHeight=986&originWidth=2360&originalType=url&ratio=1&rotation=0&showTitle=false&size=477211&status=done&style=none&taskId=u537141b6-1722-4bf7-a1b1-301efd22cce&title=)
### 可视化配置
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1657079559215-6a145e28-9547-4b2a-ad65-0f319e558f6d.png#clientId=u3f932fa8-b09c-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=ua19f989c&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1012&originWidth=2002&originalType=url&ratio=1&rotation=0&showTitle=false&size=160565&status=done&style=none&taskId=u27b45844-2ea5-4382-b9a6-da16f4305b1&title=)
### 增加告警规则
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1657079559956-391d6158-cc9e-407a-a38b-ebb7489d2771.png#clientId=u3f932fa8-b09c-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u3e904f93&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1630&originWidth=3344&originalType=url&ratio=1&rotation=0&showTitle=false&size=523627&status=done&style=none&taskId=uac45c43a-1ab5-491c-8eac-3fb73610ad7&title=)
### 查看历史告警
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1657079559776-26191b60-5f89-4b5b-887a-efc3d2d0d3a8.png#clientId=u3f932fa8-b09c-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=ue32571e5&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1504&originWidth=2876&originalType=url&ratio=1&rotation=0&showTitle=false&size=358199&status=done&style=none&taskId=ucd298a54-04b7-4085-b27a-0365055c1e6&title=)
### 场景支持

- 日志查询
- 日志报警
- 配置下发
- 快速集成
