#!/bin/bash
set -e

echo 'Wait 30s'
sleep 30

python3 /root/cgwire_checks.py
