#! /bin/bash
# FOR API 5.0
cd /opt/gateway/ && \
source env/bin/activate && \
/opt/gateway/env/bin/celery \
-A oz_gateway.celery_config \
flower \
--port=5555 \
--loglevel=INFO \
--url_prefix=/metrics/flower \
--db=/tmp/celery_flower.db \
--purge_offline_workers=3600 \
--task-runtime-metric-buckets=0.1,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,6,7,8,10,12,15,20,30,inf