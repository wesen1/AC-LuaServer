#!/bin/bash

apt-get update

# Required for luacov-multiple
apt-get install -y git


apt-get install -y luarocks

# Install the dependencies
luarocks install classic
luarocks install lua-resty-template
luarocks install ac-clientoutput

# Install the test framework dependencies
luarocks install wluaunit
luarocks install luacov
luarocks install luacov-multiple

# Install LDoc
luarocks install penlight
luarocks install ldoc

# Install luacheck
luarocks install luacheck
