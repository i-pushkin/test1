#!/bin/bash

celery -A oz_gateway.celery_config inspect ping -d preview_convert@${HOSTNAME} -j