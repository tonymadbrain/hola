# Hola api

[![Build Status](https://travis-ci.org/tonymadbrain/hola_api.svg?branch=master)](https://travis-ci.org/tonymadbrain/hola_api)

## Install

Requirements:

1. Ruby 2.3.0 or higher
2. Postgresql 9.4 or higher

Installation:

1. Fork or clone this repo
2. Create `config/database.yml` (you can use `config/database.yml.sample`)
3. Run `bundle install`
4. Create databases `bundle exec rake db:create`
5. Run migrations `bundle exec rake db:migrate`

## Tests

Just run `bundle exec rspec spec/`

## Application

Just run `ruby app.rb`

## Documentation

You can look at documentation with route `/doc`
