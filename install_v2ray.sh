#!/bin/bash
echo "this is script starting..."
apt-get update -y && apt-get install git -y
cd /app && git clone https://github.com/sugersweet/v2ray.git && cd /app/v2ray && git checkout master && chmod +x /app/v2ray/install.sh
/app/v2ray/install.sh
