FROM dunglas/frankenphp:1-php8.3 AS base
WORKDIR /app

FROM base AS deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql
COPY ./symfony/composer ./symfony/composer.json ./symfony/composer.lock ./
    
FROM deps AS dev
RUN ./composer install \
    --no-interaction \
    --no-scripts
COPY ./symfony ./

FROM deps AS build
ENV APP_ENV=prod \
    APP_DEBUG=0
RUN ./composer install \
    --prefer-dist \
    --no-scripts \
    --no-progress \
    --no-dev \
    --optimize-autoloader
COPY ./symfony ./
RUN php bin/console cache:clear --env=prod \
    && php bin/console cache:warmup --env=prod

FROM deps AS prod
ENV APP_ENV=prod \
    APP_DEBUG=0 \
    SERVER_NAME=":8080"
RUN apt-get purge -y git unzip libpq-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app ./
EXPOSE 8080
