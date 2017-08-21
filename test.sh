#!/usr/bin/env bash

./createBase.sh

awk -f createCord.awk tstCords.txt

