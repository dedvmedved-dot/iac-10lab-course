#!/bin/bash
# Склеивает части бинарника Consul в один файл
cd "$(dirname "$0")"
cat consul.part_* > consul && chmod +x consul && echo "Consul binary reassembled ($(du -h consul | cut -f1))"
