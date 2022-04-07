#!/bin/bash

/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --storage.tsdb.path=/home/data/prometheus/data &

/usr/local/grafana/bin/grafana-server --config=/usr/local/grafana/conf/defaults.ini  --homepath=/usr/local/grafana