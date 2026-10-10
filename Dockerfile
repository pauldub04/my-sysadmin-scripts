FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data
ENV LOG_FILE=/data/monitor.log

COPY script.sh start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/script.sh /usr/local/bin/start.sh

EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]

