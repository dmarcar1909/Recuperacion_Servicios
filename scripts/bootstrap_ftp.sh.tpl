#!/bin/bash
apt update -y
apt install -y docker.io docker-compose s3fs unzip

mkdir -p /ftpdata
echo "${s3fs_credentials}" > /root/.passwd-s3fs
chmod 600 /root/.passwd-s3fs
s3fs ${s3_bucket_name} /ftpdata -o passwd_file=/root/.passwd-s3fs -o url=https://s3.amazonaws.com -o use_path_request_style

mkdir -p /opt/ftp
cd /opt/ftp
docker-compose up -d