FROM wesen1/assaultcube-lua-server:1.2.0.2
RUN apt-get install -y luarocks lua5.1-0-dev librabbitmq-dev make && \
    ln -st /usr/include/ /usr/include/lua5.1/* && \
    ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/local/lib/liblua.so && \
    luarocks install lua-amqp-client && \
    luarocks install sleep
