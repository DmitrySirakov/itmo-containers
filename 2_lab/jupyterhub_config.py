import os
from jupyterhub.spawner import SimpleLocalProcessSpawner


c.JupyterHub.authenticator_class = "dummy"
c.Authenticator.allow_all = True


c.JupyterHub.ip = "0.0.0.0"
c.JupyterHub.port = 8000
c.JupyterHub.bind_url = "http://0.0.0.0:8000"

c.JupyterHub.spawner_class = SimpleLocalProcessSpawner
c.Spawner.default_url = "/lab"
c.Spawner.cmd = ["jupyterhub-singleuser"]

db_url = (
    "postgresql://"
    f"{os.environ['POSTGRES_USER']}:"
    f"{os.environ['POSTGRES_PASSWORD']}@"
    f"{os.environ['POSTGRES_HOST']}:"
    f"{os.environ['POSTGRES_PORT']}/"
    f"{os.environ['POSTGRES_DB']}"
)
c.JupyterHub.db_url = db_url

redis_host = os.environ["REDIS_HOST"]
redis_port = int(os.environ["REDIS_PORT"])
redis_password = os.environ.get("REDIS_PASSWORD", "")

if redis_password:
    c.JupyterHub.redis_url = f"redis://:{redis_password}@{redis_host}:{redis_port}/0"
else:
    c.JupyterHub.redis_url = f"redis://{redis_host}:{redis_port}/0"

c.JupyterHub.cookie_secret_file = "/tmp/jupyterhub_cookie_secret"

c.JupyterHub.log_level = os.environ.get("JUPYTERHUB_LOG_LEVEL", "INFO")
c.JupyterHub.log_file = "/var/log/jupyterhub/jupyterhub.log"

c.JupyterHub.trust_user_provided_tokens = False
c.JupyterHub.trust_user_provided_sudo = False

import tornado.web

c.JupyterHub.tornado_settings = {
    "headers": {
        "Content-Security-Policy": "frame-ancestors 'self' *",
    },
    "cookie_options": {
        "SameSite": "None",
        "Secure": True,
    },
}

tornado.web.RequestHandler._check_xsrf_cookie = lambda self: None

c.JupyterHub.concurrent_spawn_limit = 10
c.JupyterHub.active_server_limit = 20

c.JupyterHub.trusted_origins = ["*"]
c.JupyterHub.trusted_headers = [
    "x-forwarded-for",
    "x-forwarded-proto",
    "x-forwarded-host",
    "x-forwarded-port",
]
