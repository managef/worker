FROM centos:centos7

LABEL maintainer="TODO"

ENV MANAGEF_WORKER_HOME=/opt/managef \
    PATH=$MANAGEF_WORKER_HOME:$PATH

COPY managef_worker $MANAGEF_WORKER_HOME/


ENTRYPOINT ["/opt/managef/managef_worker"]