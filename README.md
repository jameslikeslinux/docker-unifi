# UniFi Network Controller for Docker

This is an opinionated take on a UniFi Network Controller container.  Because
UniFi Network Controller is so complex, this image takes the approach of
deviating as little as possible from a supported configuration.  To that end,
this image expects to be attached directly to your management network and use
Docker volumes to avoid the need for port and uid mapping.  The result is a
Dockerfile and init script a fraction of the size of the popular
[`jacobalberty/unifi`](https://hub.docker.com/r/jacobalberty/unifi/) image.
Because this image remains so close to a supported configuration, we can more
quickly respond to software updates without having to employ hacks.

## Usage

Create a Docker interface to your management network.  Suppose your management
network is on VLAN 100 with subnet 192.168.100.0/24 and accessible via the host
interface eth0.  Run the following:

```
docker network create \
  --driver macvlan \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  --opt parent=eth0.100 \
  mgmt
```

To ensure your UniFi configs persist across restarts, prepare a Docker volume
to map into the container.  Do not simply map a host directory into the
container!  Docker won't initialize it properly and UniFi almost certainly
won't have permission to write to it.

```
docker volume create unifi-network-controller
```

On a typical Docker installation, you will have access to this volume from the
host at `/var/lib/docker/volumes/unifi-network-controller/_data`.

Finally, run the container as follows:

```
docker run \
  --name unifi-network-controller \
  --net mgmt \
  --ip 192.168.100.1 \
  -v unifi-network-controller:/var/lib/unifi \
  --cap-add DAC_READ_SEARCH \
  --cap-add NET_BIND_SERVICE \
  --cap-add SETGID \
  --cap-add SETUID \
  iamjamestl/unifi-network-controller
```
