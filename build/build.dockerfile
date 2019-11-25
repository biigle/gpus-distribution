FROM docker.pkg.github.com/biigle/gpus/gpus-app
MAINTAINER Martin Zurowietz <martin@cebitec.uni-bielefeld.de>

# Configure the timezone.
ARG TIMEZONE
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && apk del tzdata

# Ignore platform reqs because the app image is stripped down to the essentials
# and doens't meet some of the requirements. We do this for the worker, though.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && COMPOSER_SIGNATURE=$(curl -s https://composer.github.io/installer.sig) \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '$COMPOSER_SIGNATURE') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && rm composer-setup.php

ENV COMPOSER_NO_INTERACTION 1
ENV COMPOSER_ALLOW_SUPERUSER 1

# Include the Composer cache directory to speed up the build.
COPY cache /root/.composer/cache

ARG GITHUB_OAUTH_TOKEN
ARG MAIA_VERSION=">=1.0"
RUN COMPOSER_AUTH="{\"github-oauth\":{\"github.com\":\"${GITHUB_OAUTH_TOKEN}\"}}" \
    php composer.phar require \
        biigle/maia:${MAIA_VERSION} \
        --prefer-dist --update-no-dev --ignore-platform-reqs

RUN sed -i '/return $app;/i $app->register(Biigle\\Modules\\Maia\\MaiaGpuServiceProvider::class);' bootstrap/app.php

COPY config/queue.php /var/www/config/queue.php
COPY config/remote-queue.php /var/www/config/remote-queue.php

RUN php composer.phar dump-autoload -o && rm composer.phar

COPY .env /var/www/.env
