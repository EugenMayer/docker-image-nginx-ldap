#!/bin/bash

set -e

docker build . -t ghcr.io/eugenmayer/nginx-ldap
