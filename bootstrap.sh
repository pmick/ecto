#!/bin/sh

carthage bootstrap --platform tvOS --cache-builds --no-use-binaries --verbose
cp Cartfile.resolved Carthage
