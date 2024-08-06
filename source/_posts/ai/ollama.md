
---
title: Ollama简介

categories:
- network

tag:
- network

---

## Ollama
Ollama 是一款命令行工具，可在 macOS 和 Linux 上本地运行 Llama 2、Code Llama 和其他模型。
目前适用于 macOS 和 Linux，并计划支持 Windows。
Ollama 目前支持近二十多个语言模型系列，每个模型系列都有许多可用的"tags"。
Tags 是模型的变体，这些模型使用不同的微调方法以不同的规模进行训练，并以不同的级别进行量化，以便在本地良好运行。
量化级别越高，模型越精确，但运行速度越慢，所需的内存也越大。

官网：https://ollama.ai/
github：https://github.com/jmorganca/ollama

## 支持模型


| Model              | Parameters | Size  | Download                       |
| ------------------ | ---------- | ----- | ------------------------------ |
| Neural Chat        | 7B         | 4.1GB | `ollama run neural-chat`       |
| Starling           | 7B         | 4.1GB | `ollama run starling-lm`       |
| Mistral            | 7B         | 4.1GB | `ollama run mistral`           |
| Llama 2            | 7B         | 3.8GB | `ollama run llama2`            |
| Code Llama         | 7B         | 3.8GB | `ollama run codellama`         |
| Llama 2 Uncensored | 7B         | 3.8GB | `ollama run llama2-uncensored` |
| Llama 2 13B        | 13B        | 7.3GB | `ollama run llama2:13b`        |
| Llama 2 70B        | 70B        | 39GB  | `ollama run llama2:70b`        |
| Orca Mini          | 3B         | 1.9GB | `ollama run orca-mini`         |
| Vicuna             | 7B         | 3.8GB | `ollama run vicuna`            |


## 运行模型

### 下载模型&运行模型

```
ollama pull llama2
```

```
ollama run llama2
```
### 查看进程
```
ps -ef |grep ollama
```
### 查看对外暴露的端口
```
lsof -i :11434
```

### 接口测试

```
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt":"Why is the sky blue?"
}'
```

### web展示
https://github.com/ollama-webui/ollama-webui
