FROM ruby:2.2.3

ENV APP_HOME /opt/geminabox

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY .ruby-version Gemfile Gemfile.lock $APP_HOME/
RUN bundle install

COPY . $APP_HOME

CMD bundle exec rackup --host 0.0.0.0 --port 9292
EXPOSE 9292
