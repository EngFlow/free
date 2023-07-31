FROM ubuntu:latest

WORKDIR /home/engflow

RUN <<-EOF
    apt-get update
    apt-get install -y build-essential python3 default-jdk git curl node.js npm
    curl -sSL https://get.docker.com/ | sh
EOF

RUN npm install -g @bazel/bazelisk

RUN git clone https://github.com/EngFlow/example.git

COPY ./example/.bazelrc ./example/engflow.bazelrc
COPY ./example/entrypoint.sh ./example/entrypoint.sh
COPY ./worker/Dockerfile ./worker/Dockerfile

ENTRYPOINT chmod +x ./example/entrypoint.sh && ./example/entrypoint.sh

