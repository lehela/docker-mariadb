#!/bin/bash
#set -x

_check_env() {
	local var="$1"
	local value=${!var}
	if [ -z "$value" ]; then
		printf "No $1 provided. Exiting .."
		return 1
	fi
	return 0
}

_check_backup() {
	if _check_env MYSQL_ROOT_PASSWORD && \ 
		_check_env MYSQL_ROOT_HOST; then
		return 0
	else
		return 1
	fi
}

_backup() {
	if ! _check_backup; then
		return 1
	fi

	echo "Executing Backup of $MYSQL_ROOT_HOST."
	rm -rf /backup/*
	mariabackup --backup \
		--target-dir=/backup \
		--host=$MYSQL_ROOT_HOST \
		--user=root --password=$MYSQL_ROOT_PASSWORD \
		--no-lock

	echo "Preparing Backup."
	mariabackup --prepare \
		--target-dir=/backup \
		--host=$MYSQL_ROOT_HOST \
		--user=root --password=$MYSQL_ROOT_PASSWORD
	# The backed up data has to be owned by msql user in order to be able to directly use the backup volume
	chown -R 999:999 /var/lib/mysql
	return 0
}
_restore() {
	rm -rf /var/lib/mysql/*
	mariabackup --copy-back --target-dir=/backup
	# The restored data has to be owned by msql user again before starting the db container on the volume
	chown -R 999:999 /var/lib/mysql
}

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

_main() {
	case "$1" in
		backup)
			_backup
			;;
		restore)
			_restore
			;;
		*)
			echo "Usage: $0 {backup|restore}"
			exit 1
	esac
}
# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
	_main "$@"
fi

