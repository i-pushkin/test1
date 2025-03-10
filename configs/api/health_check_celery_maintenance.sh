#!/bin/bash

celery -A oz_gateway.celery_config inspect ping -d maintenance@${HOSTNAME} -j