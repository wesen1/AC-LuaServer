#!/bin/bash

sudo apt-get update

# Required for luacov-multiple
sudo apt-get install git


sudo apt-get install -y luarocks

# Install the dependencies
luarocks install classic

# Install the test framework dependencies
luarocks install luacov
luarocks install luacov-multiple
luarocks install luaunit
luarocks install mach

# Install LDoc
luarocks install penlight
luarocks install ldoc

# Install luacheck
luarocks install luacheck
