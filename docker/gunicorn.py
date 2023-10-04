accesslog = "/var/log/zou/gunicorn_access.log"
errorlog = "/var/log/zou/gunicorn_error.log"
workers = 3
worker_class = "gevent"
timeout = 600
