# docker-td-agent-syslog-to-s3

docker container for td-agent as service to receive syslog at :514/udp and storing to S3.

container image is based centos:8 .

# Dependency

Amazon Linux release 2 (Karoo) or later is recommended as docker-host.

and need Docker, docker-compose.

# How to use

## `mv .env.template .env`

and edit as needed.

`.env` is automatically referenced by docker-compose.

## build image

```
docker-compose build
```

## start container

```
docker-compose up -d
```

## how to connect into container's shell

```
docker container exec -it `docker container ls -alq` /bin/bash
```

## test simple stdout

### in docker-host:

```
curl -X POST -d 'json={"json":"message2!!!"}' http://localhost:8888/debug.test
```

### and in docker-container shell:

```
tail -f /var/log/td-agent/td-agent.log
```

## test sending syslog from docker-host

*this test needs rsyslog on docker-host.*

### in docker-host:

```
sudo sh -c "echo local5.* @docker-hosts-ip:514 >> /etc/rsyslog.conf"
sudo service rsyslog restart
logger -p local5.info "I sent dummy syslog message"
```

*please replace `docker-hosts-ip`.*

### in docker-container shell:

```
tail -f /tmp/buffer.*.log
```

### and check your S3-bucket

*notice: It can take up to an hour with default td-agent.conf.*

## stop container

```
docker-compose down
```
