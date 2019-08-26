FROM biigle/gpus-build-dist AS intermediate

FROM docker.pkg.github.com/biigle/gpus/gpus-web
MAINTAINER Martin Zurowietz <martin@cebitec.uni-bielefeld.de>

COPY --from=intermediate /etc/localtime /etc/localtime
COPY --from=intermediate /etc/timezone /etc/timezone
COPY --from=intermediate /var/www/public /var/www/public
