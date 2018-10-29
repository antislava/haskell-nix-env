#!/usr/bin/env bash

# USAGE: ./set-targets-in-make.sh ./example-package ./example-package2
# echo "$@"
sedstr='/^TARGETS =/ s|\[.*\]|[ '$@' ]|'
# echo $sedstr
sed -i.bak "$sedstr" Makefile
