# vim:set ft=dockerfile:
FROM alpine:3.9 as base

FROM base as maria-backup

RUN	apk update; \
	apk add bash mariadb-backup=10.3.25-r0;

COPY mariadb-backup/mariadb-backup.sh /usr/local/bin

ENTRYPOINT [ "mariadb-backup.sh" ]
