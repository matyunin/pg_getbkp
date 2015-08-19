#!/bin/bash

usage(){
    echo "Usage: $0 DB_NAME [DEST_PATH]"
}


if [ $# -ne 1 -a $# -ne 2 ]; then
    usage
    exit 1
fi

dir=`dirname $0`
. ${dir}/config

DB_NAME=$1
[ $# -eq 2 ] && BACKUP_DIR=$2
DATETIME=`date +%Y-%m-%d_%H-%M-%S`

[ ! -e $BACKUP_DIR ] && mkdir $BACKUP_DIR

ssh -p ${SSH_PORT} ${SSH_USER}@${PG_HOST} "sudo su - postgres -c \"pg_dump $DB_NAME > ~/${DB_NAME}_${DATETIME}.sql\""
if [ $? -ne 0 ];then
    echo "Can not dump DB"
    exit 2
fi

ssh -p ${SSH_PORT} ${SSH_USER}@${PG_HOST} "sudo mv ~postgres/${DB_NAME}_${DATETIME}.sql ~${SSH_USER}"
scp -P ${SSH_PORT} ${SSH_USER}@${PG_HOST}:~/${DB_NAME}_${DATETIME}.sql ${BACKUP_DIR}/
ssh -p ${SSH_PORT} ${SSH_USER}@${PG_HOST} "rm -rf ${DB_NAME}_${DATETIME}.sql"

echo -e "\n\n\nDatabase '${DB_NAME}' succesfully dumped to $BACKUP_DIR/${DB_NAME}_${DATETIME}.sql"
