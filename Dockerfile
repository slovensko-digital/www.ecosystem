FROM ruby:2.7.8

# Install packages. Debian 11 (bullseye) of ruby:2.7.8 moved to the archive of
# Debian, deb.debian.org no longer has its security updates.
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y build-essential nodejs libpq-dev

# Set working directory
RUN mkdir /app
WORKDIR /app

# Bundle and cache Ruby gems
COPY Gemfile* ./
RUN bundle config set deployment true
RUN bundle config set without development:test
RUN bundle install

# Cache everything
COPY . .

RUN SECRET_KEY_BASE=NONE RAILS_ENV=production REDIS_URL=redis://:fake@redis:6379/15 bundle exec rails assets:precompile

# Run application by default
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
