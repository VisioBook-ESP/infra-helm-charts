#!/bin/bash

touch /tmp/test-connectivity
cd /tmp/test-connectivity

echo "Testing connectivity to services..." > /tmp/test-connectivity/

curl -v http://support-storage-service-support-storage-service:80/health >> /tmp/test-connectivity/
curl -v http://core-user-service-core-user-service:80/health >> /tmp/test-connectivity/