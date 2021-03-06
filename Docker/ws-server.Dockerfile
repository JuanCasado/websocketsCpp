FROM centos:8 as build

RUN yum install -y gcc-c++ make cmake zlib-devel openssl-devel redhat-rpm-config 

RUN groupadd app && useradd -g app app
RUN chown -R app:app /opt
RUN chown -R app:app /usr/local

COPY --chown=app:app ws-lib /opt

RUN mkdir /opt/build
WORKDIR /opt/build
RUN cmake -DUSE_TLS=1 ..
RUN make -j
RUN make install 

WORKDIR /home/app

COPY ws-server .
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN g++ main.cpp -lixwebsocket -lssl -lcrypto -lz -lpthread -o main

USER app

FROM centos:8

RUN groupadd app && useradd -g app app
WORKDIR /home/app
COPY --chown=app:app --from=build /home/app/main /home/app

CMD ["./main"]

