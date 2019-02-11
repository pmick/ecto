#!/bin/sh

if ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
  sh bootstrap.sh
fi
