#!/bin/bash

ip=`hostname -I | awk '{print $1}'`
common_name="localhost"

pushd ./certs
./generate_cert.sh $common_name -d "localhost" -i "$ip,127.0.0.1"
popd
