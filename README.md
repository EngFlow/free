# EngFlow Free Tier

EngFlow Free Tier is a single-node, standalone version of the [EngFlow
platform](https://www.engflow.com) that implements a remote cache, remote
execution service, and build web UI for [Remote Execution
v2](https://github.com/bazelbuild/remote-apis/blob/main/build/bazel/remote/execution/v2/remote_execution.proto)
protocol clients such as [Bazel](https://bazel.build).

EngFlow Free Tier may be used a remote cache and UI for any Bazel build. It can
also execute remote actions in a Linux Docker container.

## Getting started

EngFlow Free Tier is distributed as a Docker image for x86_64 Linux. The images
are hosted by the [GitHub container
registry](https://github.com/EngFlow/free/pkgs/container/free). Run the
following to start up a EngFlow Free Tier instance that stores its data in
`/tmp/engflow_data`:

    $ docker run --init --rm --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock -v /tmp/engflow_data:/tmp/engflow_data -e DATA_DIR=/tmp/engflow_data -p 8080:8080 ghcr.io/engflow/free:1.57.1

Once EngFlow starts up, it will print configuration hints for Bazel.  Try it out
as a remote executor on your own Bazel project or on the [EngFlow example
repository](https://github.com/engflow/example):

    $ git clone https://github.com/engflow/example engflow-example
    $ cd engflow-example
    $ bazel test --config engflow --bes_results_url=http://127.0.0.1:8080/invocation/ --bes_backend=grpc://127.0.0.1:8080 --remote_executor=grpc://127.0.0.1:8080 //java/...

Bazel should print a URL to view the EngFlow build UI for the build in a web
browser.

EngFlow requires a Docker image to execute remote actions in. The EngFlow
example repository configures the image using the `rbe_autoconfig` workspace
rule from
[bazel-toolchains](https://github.com/bazelbuild/bazel-toolchains). For simple
usecases, an image may be passed via Bazel's `--remote_default_exec_properties`
flag. For instance,
`--remote_default_exec_properties=container-image=docker://docker.io/ubuntu:focal-20210827`
to run remote actions in a recent Ubuntu container.

## Configuration

### Data and log storage

EngFlow stores its caches and logs in the location pointed to by the `$DATA_DIR`
environmental variable. Mount this location onto the host to preserve data
across container invocations and view the service logs. If remote execution is
used, `$DATA_DIR` must have the same path on the host and in the
container. Additionally, the Docker Unix socket must be mounted into the
container to allow EngFlow to execute actions in Docker containers.

### Setting up .bazelrc and using a custom Docker image

If you wish to use a custom image for a specific workspace add the following to
the **WORKSPACE** file:
```
git_repository(
    name = "bazel_toolchains",
    commit = "df2a96686c9751096f494d10c503426944942339",
    remote = "https://github.com/bazelbuild/bazel-toolchains.git",
)

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")
rbe_autoconfig(
    name = "engflow_remote_config",
    detect_java_home = False,
    digest = "sha256:5464e3e83dc656fc6e4eae6a01f5c2645f1f7e95854b3802b85e86484132d90e",
    java_home = "/usr/lib/jvm/java-11-openjdk-amd64",
    registry = "marketplace.gcr.io",
    repository = "google/rbe-ubuntu16-04",
)
```
Note that this example using the google/rbe-ubuntu16-04 image from GCR
Marketplace. You may use whatever image you'd like by changing the
rbe_autoconfig accordingly.

This will create a custom `@engflow_remote_config` workspace which can be
referenced via Bazel command line flags. It is reccomended that you add the
configuration to your **.bazelrc** like so:

```
build:re --action_env=BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
build:re --crosstool_top=@engflow_remote_config//cc:toolchain
build:re --extra_execution_platforms=@engflow_remote_config//config:platform
build:re --extra_toolchains=@engflow_remote_config//config:cc-toolchain
build:re --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_java11
build:re --host_javabase=@engflow_remote_config//java:jdk
build:re --host_platform=@engflow_remote_config//config:platform
build:re --java_toolchain=@bazel_tools//tools/jdk:toolchain_java11
build:re --javabase=@engflow_remote_config//java:jdk
build:re --platforms=@engflow_remote_config//config:platform
```

Then you can add the remote execution options to your **.bazelrc**:
```
build:engflow --config=re
build:engflow --remote_executor=grpc://localhost:8080
build:engflow --bes_backend=grpc://localhost:8080/
build:engflow --bes_results_url=http://localhost:8080/invocation/
```

Now you can execute against your locally running EngFlow instance by simply
adding `--config=engflow` to your build and test commands like so:
```
bazel test //... --config=engflow
```

**Warning:** The rbe_autoconfig workspace rule will add about a minute to new
builds run after `bazel clean`. Contact us for details about how to avoid this
extra delay!

## Bug reports and support

Feel free to file an issue in the GitHub tracker.

## Terms

By downloading this free version of EngFlow’s proprietary remote execution
software (the “Software”), you agree to the following terms:

- Subject to your compliance with these terms, EngFlow, Inc. (“EngFlow”) hereby grants to you a limited,
non-exclusive, non-transferable, non-sublicensable, revocable license during the
agreed upon license term to install and operate the Software, solely for your
internal use and subject to the limitations on CPU cores and machines. Any
rights not expressly granted herein are reserved by EngFlow.
- You will not and will not permit any third party to copy, modify, reverse engineer, disassemble, decompile,
decode or otherwise attempt to derive or gain improper access to any component
of the Software or develop any product or service that may compete directly or
indirectly with the Software.
- The Software is provided on an “AS-IS” basis and EngFlow disclaims all warranties, express or implied,
with respect to the Software. EngFlow will not provide customer support
obligations. You acknowledge that the Software is a free version, and
accordingly, EngFlow will not be liable to you or any third party for any
amounts with respect to the Software.
- At any time after your download and installation of the Software, without limiting EngFlow’s other rights
or remedies, EngFlow has the right to audit your use of the Software to verify
your compliance with these terms.
