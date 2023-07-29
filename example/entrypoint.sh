#!/usr/bin/env bash

sleep 5
docker login -u=engflow -p=engflow localhost:5443
docker build ./worker -t localhost:5443/engflow/worker:latest
docker push localhost:5443/engflow/worker

# echo curl -v -u engflow:engflow https://host.docker.internal:5043/v2/

pushd /home/engflow/example || exit 1
bazel --bazelrc=engflow.bazelrc build //cpp/... --config=engflow