#!/usr/bin/env bash
pkill -x quickshell 2>&1
echo "qs killed"
qs -d > ~/qs_path.log 2>&1
echo "qs started"
