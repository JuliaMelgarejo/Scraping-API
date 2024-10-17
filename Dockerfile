FROM ruby:3.1

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . . 

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
