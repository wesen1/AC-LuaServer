FROM wesen1/assaultcube-lua-server:1.2.0.2-lib-lua
COPY test-server/rocks /rocks
RUN apt-get install -y luarocks && \
    luarocks install /rocks/ac-luaserver-0.0.5-1.src.rock
