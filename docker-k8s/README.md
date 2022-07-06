# Container image for eturnal STUN/TURN Server

This is a multi-arch [eturnal](https://eturnal.net/) image based on [Alpine Linux](https://alpinelinux.org) and currently built for:

* linux/amd64
* linux/386
* linux/s390x
* linux/ppc64le
* linux/arm64
* linux/arm/v7
* linux/arm/v6

The image is available as `ghcr.io/processone/eturnal` from [GitHub Packages](https://github.com/processone/eturnal/pkgs/container/eturnal).

## Tags

`XX.YY.ZZ` represents the official eturnal release, a `-AA` suffix the image version of a particular release in case of any bug fix etc. of the image. Images are available from version `1.8.4` onwards.

| Tags  | Description  | Additional notes  |
| ------------ | ------------ | ------------ |
| `edge`  | Built from `master` branch, see [changelog](https://github.com/processone/eturnal/blob/master/CHANGELOG.md)  | For testing purposes.  |
| `1.8.4`, `latest`  | [Release changelog](https://github.com/processone/eturnal/releases/tag/1.8.4)  |   |

Images are scanned daily by [Trivy](https://www.aquasec.com/products/trivy) and, if necessary, the `latest` release will be rebuilt and updated.

## Usage with [Docker](https://www.docker.com)

To pull the image:

    docker pull ghcr.io/processone/eturnal:latest

Docker will run a container named `eturnal` in `foreground` mode with default ports published, if started this way:

```shell
docker run -d --rm \
    --name eturnal \
    -p 3478:3478 \
    -p 3478:3478/udp \
    -p 49152-65535:49152-65535/udp \
  ghcr.io/processone/eturnal:latest
```

**Recommended:** The container can also run in a less privileged mode:

```shell
docker run -d --rm \
    --name eturnal \
    --user 9000:9000 \
    --security-opt no-new-privileges \
    --cap-drop=ALL \
    --read-only \
    -p 3478:3478 \
    -p 3478:3478/udp \
    -p 49152-65535:49152-65535/udp \
  ghcr.io/processone/eturnal:latest
```

As an alternative, since Docker [performs badly with large port ranges](https://github.com/instrumentisto/coturn-docker-image/issues/3), use the [host network](https://docs.docker.com/network/host/) by adding `--network=host` to the command line:

```shell
docker run -d --rm \
    --name eturnal \
    --user 9000:9000 \
    --security-opt no-new-privileges \
    --cap-drop=ALL \
    --read-only \
    --network=host \
  ghcr.io/processone/eturnal:latest
```

**Note:** The Docker container is no longer isolated from the [host network](https://docs.docker.com/network/host/) when using this option.

Inspect the running container with:

    docker logs eturnal

To use the `eturnalctl` [command](https://eturnal.net/documentation/#Operation), e.g. just run:

    docker exec eturnal eturnalctl info

Stop the running container with:

    docker stop eturnal

## Configuration

Configuration is mainly done by a mounted `eturnal.yml` file (recommended), see the [example configuration file](https://github.com/processone/eturnal/blob/master/config/eturnal.yml). The file must be readable by the eturnal user (`chown 9000:9000` and `chmod 640`). **Mountpath**, e.g. with `docker run` add:

    -v /path/to/eturnal.yml:/opt/eturnal/etc/eturnal.yml

eturnal may also be configured by specifying certain environment variables, see the [documentation](https://eturnal.net/documentation/#Environment_Variables). Here are some more hints [how to configure eturnal](https://eturnal.net/documentation/#Global_Configuration).

**Note:** 

* For logs to be printed with the `docker logs` command, `log_dir:` should be set to `stdout` in `eturnal.yml`.
* When `--network=host` setting is not used, the IPv4 autodetection is most likely unsuccesful. Therefore, the [relay_ipv4_addr](https://eturnal.net/documentation/#relay_ipv4_addr) parameter must be set in such cases with a mounted `eturnal.yml` file.
* The default turn range `49152-65535/udp` may be decreased with the [relay_min_port and relay_max_port](https://eturnal.net/documentation/#relay_min_port) options, if one experiences [performance issues](https://github.com/instrumentisto/coturn-docker-image/issues/3) and does not want to use `--network=host` option with the `docker run` command. A different, new range must be reflected also in the `docker run` command `--publish`-option, 
    * e.g. `-p 50000-50500:50000-50500/udp` for specified `relay_min_port: 50000` and `relay_max_port: 50500` in `eturnal.yml`

## Custom TLS certificates and dh-parameter file

To use eturnal's TLS listener with cutsom TLS certificates/dh-parameter files they must be mounted into the container and [referenced](https://eturnal.net/documentation/#tls_crt_file) in the `eturnal.yml` file. TLS certificates and the dh-parameter file shall be `.pem` files. They must be readable by the eturnal user/group `9000:9000` and should not have world-readable access rights (`chmod 400`). **Mountpath**, e.g. with `docker run` add:

    -v /path/to/tls-files:/opt/eturnal/tls

## Examples for Docker Compose and Kubernetes

This repository also contains configuration examples for:

* [Docker Compose](https://github.com/processone/eturnal/tree/master/docker-k8s/examples/docker-compose)
* [Kubernetes (Kustomize)](https://github.com/processone/eturnal/tree/master/docker-k8s/examples/kubernetes-kustomize)