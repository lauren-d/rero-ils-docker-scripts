# Production environment installation overview

This guide provide a way to simulate a full production environment of RERO-ILS.

In addition to the normal ``docker-compose.yml``, this one will start:

- HAProxy (load balancer)
- Nginx (web frontend)
- UWSGI (application container)
- Celery (background task worker)
- Celery (background task beat)
- Flower (Celery monitoring)

**NOTE: this guide coudn't be use to run RERO-ILS in production deployment**

## Requirements
  - Git
  - Docker (with docker-compose-plugin or docker-compose)

## Build RERO-ILS

To help you to simulate a production environment, all you need to build and 
deploy service is to clone rero-ils-docker-scripts repository:

https://github.com/lauren-d/rero-ils-docker-scripts

**!! WARNING !!**
**It isn't an official Rero repository.**
**We strongly advise against using it in production.**

```
$ git clone https://github.com/lauren-d/rero-ils-docker-scripts.git
$ cd rero-ils-docker-scripts
```

### Repository overview
```
rero-ils-docker-scripts
├── docker
│   ├── elasticsearch
│   │   └── Dockerfile
│   ├── haproxy
│   │   ├── Dockerfile
│   │   ├── haproxy_cert.pem
│   │   └── haproxy.cfg
│   ├── nginx
│   │   ├── conf.d
│   │   │   └── default.conf
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   ├── test.crt
│   │   └── test.key
│   ├── postgres
│   │   ├── Dockerfile
│   │   └── init-app-db.sh
│   ├── uwsgi
│   │   ├── uwsgi_rest.ini
│   │   └── uwsgi_ui.ini
│   └── wait-for-services.sh
├── docker-compose.full.yml
├── Dockerfile
├── Dockerfile.base
├── docker-services.yml
├── includes
│   └── messages.sh
├── init.sh
├── instance
│   └── invenio.cfg
├── README.md
```
## Command Line Interface:

```
$ ./init.sh
Error : You need to specify a command.
Info : usage: ./init.sh COMMAND [ARGUMENTS]
    clone             clone RERO-ILS sources
    build             build docker image from Dockerfile
      -a|--all                        build rero-ils-base and rero-ils images
      -t|--tgz_package <file_path>    rero-ils-ui tgz package
    start             start rero-ils (production mode)
    restart           restart rero-ils
    stop              stop rero-ils
    destroy           remove and destroy all (containers, networks, volumes)
    setup             run RERO-ILS setup
```

Clone rero-ils and build docker images:

```
$ ./init.sh clone
$ ./init.sh build -a   
```
**note**:
`-a` is needed the first time to build rero-ils-base image

Start all docker services

```
$ ./init.sh start
```

Run RERO-ILS setup
```
$ ./init.sh setup
```

Visit https://localhost in a web browser

#### invenio.cfg

`invenio.cfg` can be used to override some variables regarding our deployment.

**note**: `invenio.cfg` is mounted using docker volume on `/invenio/var/instance/invenio.cfg` (see docker-compose.full.yml)


When you update invenio.cfg, you need to reload containers to apply change:
```
$ ./init.sh restart
```
