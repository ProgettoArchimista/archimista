FROM phusion/passenger-ruby21:0.9.27
# Install needed dependencies to build native extensions for ruby
RUN apt-get update && \
	apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client --fix-missing --no-install-recommends && \
	apt-get install -qq -y --fix-missing --no-install-recommends libmysqlclient-dev && \
	apt-get install -qq -y --fix-missing --no-install-recommends libpq-dev && \
	apt-get install -qq -y --fix-missing --no-install-recommends libsqlite3-dev && \
	apt-get install -qq -y --fix-missing --no-install-recommends tzdata

# RUN /usr/sbin/enable_insecure_key

# ENV INSTALL_PATH /home/app/webapp

# Configure NGINX + PASSENGER
RUN rm /etc/nginx/sites-enabled/default && \
	rm -f /etc/service/nginx/down
COPY server/archimista.conf /etc/nginx/sites-enabled/archimista.conf
# COPY server/rails-env.conf /etc/nginx/main.d/rails-env.conf

# COPY server/nginx.conf /etc/nginx/nginx.conf

VOLUME ["/home/app/webapp"]
ENV HOME /home/app/webapp

# COPY --chown=app:app Gemfile /home/app/webapp/Gemfile
COPY --chown=app:app . /home/app/webapp
# USER app
# RUN cp -R /home/app/archimista/* /home/app/webapp/
WORKDIR /home/app/webapp

USER app
RUN bundle install

USER root
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]




# # Dockerfile
# 
# FROM phusion/passenger-ruby21:0.9.15
# 
# # Set correct environment variables.
# ENV HOME /root
# 
# # Use baseimage-docker's init system.
# CMD ["/sbin/my_init"]
# 
# # Expose Nginx HTTP service
# EXPOSE 80
# 
# # Start Nginx / Passenger
# RUN rm -f /etc/service/nginx/down 
# 
# # Remove the default site
# RUN rm /etc/nginx/sites-enabled/default
# 
# # Add the nginx site and config
# COPY server/archimista.conf /etc/nginx/sites-enabled/webapp.conf
# COPY server/rails-env.conf /etc/nginx/main.d/rails-env.conf
# 
# # Install bundle of gems
# WORKDIR /tmp
# COPY Gemfile* /tmp/
# RUN bundle install
# 
# # Add the Rails app
# COPY --chown app:app . /home/app/webapp
# 
# # Clean up APT and bundler when done.
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*