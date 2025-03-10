#!/bin/bash

celery -A oz_gateway.celery_config inspect ping -d regula@${HOSTNAME} -j