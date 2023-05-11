#!/bin/bash
docker build -t tli551/samba-ad:v0.1.0 .
docker rmi -f $(docker images -f "dangling=true" -q)
