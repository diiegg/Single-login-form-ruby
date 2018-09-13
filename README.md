### Rails App, Deploy it with Unicon and Nginx on Ubuntu 14.04

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

### Ruby version
```

ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux]
```

### Rails Version
```
Rails 5.2.1
```

### System dependencies
```
NGinx
Postgre Database
Unicorn
Ubuntu server 14.06
```

## Configure the enviroment 
 ###### Using Chef to deploy the Server Stack 
 ```
Ubuntu 16.04
PostgreSQL
Redis
Monit
RVM
Node.js
Nginx
Ncdu
```
### Install and Deploy in a existing Produciton Enviroment 

###### Install
 ```
git clone https://github.com/diiegg/Single-login-form-ruby.git
cd rails-api-template
bundle install
rails db:create
rails db:migrate
rails s

```
###### Deploy
 ```
cap production deploy
cap production deploy:upload_configs
cap production deploy

Next releases:
cap production deploy

Additional tasks:
cap production app:stop
cap production app:start
cap production app:restart

```
### Create a new Production Enviroment

### Production Database User creation
```
sudo -u postgres createuser -s appname
sudo -u postgres psql
postgres=# \password **appname**
postgres=# \q
```

### Production Database Connection

###### Ensure that you are in your application's root directory (cd ~/appname).
```
nano config/database.yml (add the following line under it (if it doesn't already exist):)

host: localhost
username: **appname***
password: <%= ENV['APPNAME_DATABASE_PASSWORD'] %>
```

### Database Production creation
```
RAILS_ENV=production rake db:create
```

###### Generate a Controller
```
rails generate scaffold Task title:string note:text
RAILS_ENV=production rake db:migrate
```
    
### Database Precomile Assets
```
RAILS_ENV=production rake assets:precompile
```

### How to run the test suite
```
RAILS_ENV=production rails server --binding=server_public_IP
```

## Services (job queues, cache servers, search engines, etc.)

### Deployment instructions

## Create a Unicorn Script
```
sudo vi /etc/init.d/unicorn_appname
```
##Copy and paste the following code replace User and APPname with appropriate values
```
#!/bin/sh

### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the unicorn app server
# Description:       starts unicorn using start-stop-daemon
### END INIT INFO

set -e

USAGE="Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"

# app settings
USER="**username**"
APP_NAME="**appname**"
APP_ROOT="/home/$USER/$APP_NAME"
ENV="production"

# environment settings
PATH="/home/$USER/.rbenv/shims:/home/$USER/.rbenv/bin:$PATH"
CMD="cd $APP_ROOT && bundle exec unicorn -c config/unicorn.rb -E $ENV -D"
PID="$APP_ROOT/shared/pids/unicorn.pid"
OLD_PID="$PID.oldbin"

# make sure the app exists
cd $APP_ROOT || exit 1

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
  test -s $OLD_PID && kill -$1 `cat $OLD_PID`
}

case $1 in
  start)
    sig 0 && echo >&2 "Already running" && exit 0
    echo "Starting $APP_NAME"
    su - $USER -c "$CMD"
    ;;
  stop)
    echo "Stopping $APP_NAME"
    sig QUIT && exit 0
    echo >&2 "Not running"
    ;;
  force-stop)
    echo "Force stopping $APP_NAME"
    sig TERM && exit 0
    echo >&2 "Not running"
    ;;
  restart|reload|upgrade)
    sig USR2 && echo "reloaded $APP_NAME" && exit 0
    echo >&2 "Couldn't reload, starting '$CMD' instead"
    $CMD
    ;;
  rotate)
    sig USR1 && echo rotated logs OK && exit 0
    echo >&2 "Couldn't rotate logs" && exit 1
    ;;
  *)
    echo >&2 $USAGE
    exit 1
    ;;
esac
* ...
 * Set permissions and enable Unicorn 

    sudo chmod 755 /etc/init.d/unicorn_appname
    sudo update-rc.d unicorn_**appname** defaults
```
   
## Feed the Unicorn
```
sudo service unicorn_appname start
```
### Install and Configure Nginx
```
sudo apt-get install nginx

sudo nano /etc/nginx/sites-available/default
```

#### Replace Username and appname with the appropriate values
```
upstream app {
    # Path to Unicorn SOCK file, as defined previously
    server unix:/home/**username**/**appname**/shared/sockets/unicorn.sock fail_timeout=0;
}

server {
    listen 80;
    server_name localhost;

    root /home/**username**/**appname**/public;

    try_files $uri/index.html $uri @app;

    location @app {
        proxy_pass http://app;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;
}
```

### Restatr Nginx
```
sudo service nginx restart
```

### Now the production environment of your Rails application is accessible via your server's public IP address or FQDN.
```
http://server_public_IP
