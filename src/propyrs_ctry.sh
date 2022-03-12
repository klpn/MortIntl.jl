#!/bin/sh
grep -h "^$1" ../data/Mort* | awk -v ca1="$2" -v ca2="$3" -v li="$4" \
        -f propyrs_ctry.awk
