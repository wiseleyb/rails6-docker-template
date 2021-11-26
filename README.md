# WTF? :)

This is my first attempt to build a sort of start point for common rails projects with Rails 6. It's a bit of a mess so, user beware.

# Setup

1. install (docker)[https://www.docker.com/get-started]
2. clone `git clone https://github.com/wiseleyb/rails6-docker-template'
3. `docker-compose build`
4. `docker-compose run web bundle exec rake db:setup`
5. `docker-compose run web bundle exec rake db:migrate`
6. `docker-compose up`
7. Go to `localhost:3000`

# Command line alias'

Just dump these in your bash_profile/zshrc/etc ... saves on typing

```
alias dcomp='docker-compose'
alias dcup='docker-compose up'
alias dcbuild='docker-compose build'
alias dccon='docker-compose exec web rails console'
alias dcrails='docker-compose run web bundle exec rails'
alias dcrake='docker-compose run web bundle exec rake'
```

# feature/redis

Based on https://yizeng.me/2019/11/16/use-redis-for-caching-to-a-docker-compose-managed-rails-project/

`ENV:REDIS_URL_CACHING` needs to be set when you deploy to point at whatever you're using for a redis store

# feature/Sidekiq

Based on https://yizeng.me/2019/11/17/add-sidekiq-to-a-docker-compose-managed-rails-project/

Depends on feature/redis

`ENV:REDIS_URL_SIDEKIQ` needs to be set for redis url

# feature/gql

Based on https://evilmartians.com/chronicles/graphql-on-rails-1-from-zero-to-the-first-query

Note: Generator `rails g graphql:object article`

See app/graphql/README.md for examples of GQL queries, subscriptions and mutations and more links to where this code came from.  Note: the subscription stuff requires signing up for a website.

# feature/react

A super basic react page - just to make sure webpacker, etc is working

# feature/active-admin

Very basic "does it work" active-admin setup. Note: this is mostly because I'm migrating a large project using this - there are much better admin options out there now... just google.

# Original Doc follows

# Rails 6 on Docker demo application

![Ruby](https://github.com/ryanwi/rails-on-docker/workflows/Ruby/badge.svg)

This app demonstrates Rails 6 with PostgreSQL and Webpacker, all running in Docker.

**NOTE:** [There is also an example Rails 7 application working in Docker without Webpack or node.js](https://github.com/ryanwi/rails7-on-docker)

## Initial setup
```
docker compose build
docker compose run --rm web bin/rails db:setup
```

## Running the Rails app
```
docker compose up
```

## Running the Rails console
When the app is already running with `docker-compose` up, attach to the container:
```
docker compose exec web bin/rails c
```

When no container running yet, start up a new one:
```
docker compose run --rm web bin/rails c
```

## Running tests
```
docker compose run --rm web bundle exec rspec
```

## Updating gems
```
docker compose run --rm web bundle update
docker compose up --build
```

## Updating Yarn packages
```
docker compose run --rm web yarn upgrade
docker compose up --build
```

## To connect to the database in postico

* stop postgres running locally on your box
* host: 0.0.0.0
* post: 5432
* un: postgres
* pw: changeme
* db: {app_name}_development

## Debugging

If you put a `byebug` in your code to debug with you need to do this:

1) `docker container ls` - find the id for the `web` container
2) `docker attach {container-id}`

## Credits/References

* https://docs.docker.com/compose/rails/
* https://rubyinrails.com/2019/03/29/dockerify-rails-6-application-setup/
* https://pragprog.com/book/ridocker/docker-for-rails-developers
* https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
* https://medium.com/@cristian_rivera/cache-rails-bundle-w-docker-compose-45512d952c2d

For Webpack dev server:
* https://github.com/rails/webpacker/blob/master/docs/docker.md
* https://github.com/rails/webpacker/issues/863
* https://github.com/rails/webpacker/issues/1019
