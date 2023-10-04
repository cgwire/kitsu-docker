accesslog = "/var/log/zou/gunicorn_events_access.log"
errorlog = "/var/log/zou/gunicorn_events_error.log"
workers = 1
worker_class = "geventwebsocket.gunicorn.workers.GeventWebSocketWorker"
