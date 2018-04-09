FROM alpine:edge
MAINTAINER Yassine Echabbi <github.com/yassine>

ENV GOPATH /go-workspace
ENV CONSUL_PATH /consul
ENV CONSUL_VERSION v1.0.6
ENV PATH $GOPATH/bin:$PATH

ADD ./config /etc/config/
ADD ./CONSUL_VERSION /etc/VERSION
RUN apk update \
    && apk upgrade \
    # Build Deps
    && apk add --no-cache --virtual .build-deps \
        make \
       	"go=1.10.1-r0" \
        git \
        gcc \
        libc-dev \
        libgcc \
        bash \
    && go get -u github.com/magiconair/vendorfmt/cmd/vendorfmt \
    && mkdir -p $GOPATH/src/github.com/hashicorp $GOPATH/bin \
    && cd $GOPATH/src/github.com/hashicorp \
    && export CONSUL_VERSION=$(cat /etc/VERSION) \
    && git clone --branch $CONSUL_VERSION https://github.com/hashicorp/consul.git \
    && cd consul
    && make dev \
    && cp bin/consul /bin/consul \
    && addgroup consul \
    && adduser -D -g "" -s /bin/sh -G consul consul \
    && mkdir -p /var/consul \
    && chown -R consul:consul /etc/config/consul /var/consul \
    && apk del .build-deps \
    && rm -rf $GOPATH /var/cache/apk/*

ENTRYPOINT ["consul"]
CMD ["agent", "-dev", "-config-dir", "/etc/config/consul"]

