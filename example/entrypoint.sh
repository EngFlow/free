#!/usr/bin/env bash

sleep 5
docker login -u=engflow -p=engflow localhost:5443
docker build ./worker -t localhost:5443/engflow/worker:latest
docker push localhost:5443/engflow/worker

pushd /home/engflow/example || exit 1
bazel clean
bazel --bazelrc=engflow.bazelrc build //cpp/... --config=engflow