FROM postgres:18 AS dev
WORKDIR /docker-entrypoint-initdb.d
COPY ./init/ ./
RUN chmod +x ./