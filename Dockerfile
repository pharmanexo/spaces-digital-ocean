# Use a imagem base oficial do PHP 7.4-FPM
FROM php:7.4-fpm

ARG uid
ARG user

# Instale as dependências necessárias (Curl)
RUN apt-get update && apt-get install -y curl

# Instale o utilitário 'unzip' para lidar com arquivos ZIP
RUN apt-get install -y unzip

# Instale as extensões mais comuns do PHP
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libmcrypt-dev \
    libxml2-dev \
    zlib1g-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql zip mbstring xml curl json opcache


# Instale a extensão SOAP
RUN apt-get update && apt-get install -y libxml2-dev
RUN docker-php-ext-install soap


# Copie sua configuração personalizada do PHP, se desejar
# COPY php.ini /usr/local/etc/php/

# Create System USER to run commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user && \
    chown -R $user:$user /var/www
RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user
RUN printf '[PHP]\ndate.timezone = "America/Sao_Paulo"\n' > /usr/local/etc/php/conf.d/tzone.ini

#Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Defina a versão do PHP usada pelo Composer (ajuste conforme necessário)
ENV COMPOSER_PLATFORM_OVERRIDE php:7.4

COPY execute.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/execute.sh

USER $user
# Defina o diretório de trabalho padrão
WORKDIR /var/www

# Exponha a porta do PHP-FPM (opcional)
EXPOSE 9000

# Inicialize o PHP-FPM
CMD ["php-fpm"]