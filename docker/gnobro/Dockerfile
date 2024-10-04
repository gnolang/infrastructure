FROM ghcr.io/gnolang/gno/gnobro:master

ENV UID=1000
ENV GID=1000
ENV USER=gno
ENV GROUP=gno

RUN addgroup -g $GID $GROUP && \
    adduser --shell /sbin/nologin --disabled-password \
    --no-create-home --uid $UID --ingroup $GROUP $USER

USER $USER
