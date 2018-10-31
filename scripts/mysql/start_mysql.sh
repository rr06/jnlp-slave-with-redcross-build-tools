#!/usr/bin/env bash

# requires root
/etc/init.d/mysql start

ROOT_PWD="${ROOT_PWD:-test}"
mysqladmin -u root password "${ROOT_PWD}"
