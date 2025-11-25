FROM minio/minio:RELEASE.2025-09-07T16-13-09Z AS dev

COPY dev_config.sh /usr/local/bin/dev_config.sh
RUN chmod +x /usr/local/bin/dev_config.sh

ENTRYPOINT ["/usr/local/bin/dev_config.sh"]