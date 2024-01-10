#!/bin/bash
echo "########### Instalando as dependencias do composer ##############"
composer install --no-interaction --optimize-autoloader

echo "########### INICIA O FPM ##############"
php-fpm



