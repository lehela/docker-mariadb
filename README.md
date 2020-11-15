# Raspberry Pi MariaDB Docker Repository

This is a repository with which I'm learning Docker containerization. As i have a need for MariaDB containers for my Raspberry Pi I thought cloning and adapting the Docker "Official Image" which does not support armhf architecture will help me learn faster. Further, I'm documenting my setup here, but this is part of my learning process.

I'm aware that there are excellent existing MariaDB images for ARM architecture, e.g. by [LinuxServer.io](https://hub.docker.com/r/linuxserver/mariadb). Please pay them a visit if you are looking for good & reliable Docker images to run on a Raspberry Pi.

### Forked from https://github.com/docker-library/mariadb

This is the Git repo of the [Docker "Official Image"](https://github.com/docker-library/official-images#what-are-official-images) for [`mariadb`](https://hub.docker.com/_/mariadb/) adapted to run on Raspberry Pi's armhf architecture. 

See [the Docker Hub page](https://hub.docker.com/_/mariadb/) for the full readme on how to use the mariadb Docker image and for information regarding contributing and issues.

### Basic Usage

To start from scratch, ensure that Volumes defined in the `docker-compose.yml` do not exist. To be sure, and remove any existing volumes run:
```
docker-compose down -v
```
Next, bring up the `db` service, which maps the MariaDB to the outside on port `3310`.
```
docker-compose up -d db
```
Take note of the container name assigned by `docker-compose` (e.g. _mariadb_db_1_). Ensure, that this name is used for the `MYSQL_ROOT_HOST` environment variable in the `docker-compose.yml` also for the `db_tool` service.

Connect to the database running on the Docker host on port 3310 with CLI, or HeidiSQL, etc as _root_ using the password that is provided in the `MYSQL_ROOT_PASSWORD` environment variable in the `docker-compose.yml` file.

---
## Docker based Backup & Restore of Data Volumes
The docker service `db_tool` backs up & restores the database's volume `mariadb_data` connected to the `db` service.
### Backup

To backup, run the following command. This can be done without stopping the `db` service.
```
docker-compose run --rm db_tool backup
```
Note, that the backup volume itself could be used as the data volume of another `mariadb` container.

### Restore
Before restoring from the backup volume, the `db` service must be down:
```
docker-compose down
```
Do not use the `-v` flag or else the data container itself gets deleted... duh.
Next, use the `db_tool` to restore the backup volume to the `mariadb_data` volume.
```
docker-compose run --rm db_tool restore
```
Finally, spin up the `db` service again to continue working.
```
docker-compose up -d db
```
### Cloning Backup Volumes
As the backup volume name is specified in the `docker-compose.yml`, any subsequent `db_tool backup` run will overwrite previous backups.

Guido Diepen has written a shell script that clones Docker Data Volumes (Link: [Cloning Docker Data Volumes](https://www.guidodiepen.nl/2016/05/cloning-docker-data-volumes/))

This script can  be used e.g. to generate timestamp based clones of the main backup volume. 

```
$ docker_clone_volume.sh \
mariadb_mariadb-backup \
mariadb_mariadb-backup_20201115
```
Same as the main backup volume, the cloned data volumes can be directly used as main data volumes for other `mariadb` container instances.