# How to use this:

This project has various branches that add various features to docker Rails 6

* `main`: is just `feature/base`
* `feature/everything`: contains all features below
* `feature/base`: this is the base project which is just https://github.com/ryanwi/rails-on-docker
* `feature/redis`: adds redis
* `feature/devise`: adds despise-devise (still needs lots of work)
* `feature/active-admin`: adds very basic activeadmin code (still needs cancan and admin_users should be mixed with users)

So - if you just wanted docker with redis you could `git co my-custom-docker; git merge feature/base; git merge feature/redis`

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
