# Alpine slim-based image
FROM nginx:stable-alpine

# Runtime arguments from docker-compose
ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

# Remove conflicting group if exists (applies to Mac)
RUN delgroup dialout

# Add user
RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel
RUN sed -i "s/user  nginx/user laravel/g" /etc/nginx/nginx.conf

# Apply nginx configuration from config
COPY ./../config/nginx.conf /etc/nginx/conf.d/default.conf