FROM php:7.4-cli


# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*


# Extensiones PHP necesarias (PDO + SQLite)
RUN docker-php-ext-install pdo pdo_sqlite


# Instalar Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"


# Copiar el proyecto al contenedor
WORKDIR /app
COPY . .


# Instalar dependencias PHP
RUN composer install --no-interaction


# Crear el esquema de la base de datos SQLite
RUN php console create-schema || echo "⚠ Aviso: create-schema falló en build, ejecútalo luego si hace falta"


# Permisos necesarios (logs, cache y base de datos)
RUN chmod -R 777 logs cache config || true \
    && chmod -R 777 config/schema.sqlite || true


# Exponer puerto 80
EXPOSE 80


# Arrancar el servidor embebido de PHP sobre la carpeta web/
CMD ["php", "-S", "0.0.0.0:80", "-t", "web"]
