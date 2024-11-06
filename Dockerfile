FROM ruby:3.1

# Instalar dependencias necesarias
RUN apt-get update -qq && \
    apt-get install -y nodejs postgresql-client redis-tools

WORKDIR /app

# Copiar Gemfile y Gemfile.lock
COPY Gemfile* ./ 

# Instalar las gemas
RUN bundle install

# Copiar el resto de la aplicación
COPY . . 

# Exponer el puerto 3000 para el servidor
EXPOSE 3000

# Comando para iniciar el servidor
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
