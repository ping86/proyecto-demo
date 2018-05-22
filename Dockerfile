FROM opositatest/symfony-nginx:latest

#ARG DATABASE_URL=sqlite:///%kernel.project_dir%/var/data/blog.sqlite
#ARG MAILER_URL=null://localhost

COPY . /app


#node and gulp
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -  && \
    apt-get install -y nodejs build-essential && \
    npm install -g yarn  && \

    apt-get install -y php7.1-sqlite  && \
    phpenmod sqlite && \

    service redis-server start && \

    #Deploy keys configuration
    mkdir -p /root/.ssh/ && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org  >> ~/.ssh/known_hosts && \

    composer install --optimize-autoloader --no-interaction --no-ansi && \

    #Remove build dependencies
    service redis-server stop && \
    apt-get autoremove -y redis-server && \

    apt-get remove -y build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  && \

    mkdir -p var && \

    chown -R www-data:www-data var /var/ngx_pagespeed_cache

    #bin/console assets:install --env=prod --no-debug  && \

    CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]