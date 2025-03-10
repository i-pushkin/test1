# Docker-compose for separated API & OZ services

List of services to be launched

| Service                                                                  | Description                                                                                                         | Comments                         |
|--------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|----------------------------------|
| API with gunicorn                                                        | Provides RESTful application programming interface to the core functionality of Liveness and Face matching analyses |                                  |
| Celery (default, maintenance, resolution, preview_convert, tfss, regula) |                                                                                                                     |                                  |
| Redis                                                                    |                                                                                                                     |                                  |
| Nginx                                                                    |                                                                                                                     |                                  |
| WebUI                                                                    | Convenient user interface that allows to explore the stored API data                                                |                                  |
| Statistics                                                               |                                                                                                                     |                                  |
| TFSS                                                                     |                                                                                                                     | Сan be run on a separate host    |
| Postgres                                                                 |                                                                                                                     | An external database can be used |
| O2N                                                                      |                                                                                                                     |                                  |
| Postgres for O2N                                                         |                                                                                                                     | An external database can be used |
| External exporter for Celery                                             |                                                                                                                     |                                  |
| External exporter for Redis                                              |                                                                                                                     |                                  |
| External exporter for Postgres                                           |                                                                                                                     |                                  |
| External exporter for Nginx                                              |                                                                                                                     |                                  |
| bio-updater | Designed to general download and update model versions. Works with bio-initer | Recommended to install on a separate host |
| bio-initer | Designed to separeted download and update model versions for TFSS | Need to set up on host with TFSS |
| WebSDK                                                                   | With WebSDK, you can take photos and videos of people via their web browsers and then analyze these media.          |                                  |

## Hardware requirements for all-in-one setup

The following resources are required to launch the services:

| vCPU | RAM | Disk       |
|------|-----|------------|
| 16   | 32  | 100 GB SSD |

Docker version 19.03 and higher and Docker Compose version 1.27 and higher.

Podman version 4.4 and higher and podman-compose version 1.2.0 and higher.

## Initial setup

### License

Put the license file for TFSS at `./configs/tfss/license.key`.

Put the license file for WebSDK at `./configs/websdk/license.json`.

### Client token

Put the token value at param UPDATER_CLIENT_TOKEN at `./configs/config.env`. Additionally set host IP address with component bio-updater at param UPDATER_FTP_SERVER_HOST.

### Firewall

Ensure that the firewall rules allow access to the following ports:

| Service                        | Port | Notes     |
|--------------------------------|------|-----------|
| API                            | 8000 |           |
| TFSS                           | 8501 | Only for connection to host API |
| WebUI                          | 80   |           |
| External exporter for Celery   | 5555 |           |
| External exporter for Redis    | 9117 |           |
| External exporter for Postgres | 9187 |           |
| External exporter for Nginx    | 9113 |           |
| TFSS loadbalancer              | 9501 | Optional  |
| bio updater                    | 8521, 60000-60100 | |
| WebSDK http                    | 8080 | Optional  |
| WebSDK https                   | 15080| Optional  |

## Check requirements

Before starting system configuration, it is recommended to run the host readiness check scripts.

### Docker All-In-One

Navigate to the checkers directory and run the pre-checker-all.sh script. The script must be run with sudo.
```bash
sudo ./pre-checker-all.sh
```

### Docker Separated

To check the bio host, navigate to the checkers directory on the respective host and run the pre-checker-bio.sh script.

```bash
./pre-checker-bio.sh
```

To check the api host, navigate to the checkers directory on the respective host and run the pre-checker-api.sh script.

```bash
./pre-checker-api.sh
```

## Configuration

### Initial passwords and values prefill required:

* configs\api\config.py
  - Line 15: 'PORT' = Same port as set in configs\nginx\default.conf line 2. Used to set urls to serve static via nginx.
  - Line 21: 'HOST' = Same name as set in docker-compose for oz-api-nginx container. Used to set urls to serve static via nginx.
  - Line 24-28: 'DB_*' = Params for connecting po PG DB. Must refer to oz-api-pg name, params set in configs\init\init-db.sh, configs\postgres\init.sql
  - Line 33-34: '*TFSS*' = Must refer to oz-tfss container name & port, set in docker-compose.yaml oz-tfss start command.
  - Line 36: Regula. Currently only external regula supported.
  - Line 54-57: Redis connection. Change password or redis container name and port, corresponging to configs\redis\redis.conf, line 2,4.
  - Line 69: Celery workers healthcheck list. Remove Celery workers from list, if you disable them in docker-compose.yaml
  - Line 141: O2N. Change o2n name and port, corresponding to docker-compose.yaml


* configs\init\init-*.sh
  - VARS section of each file (Lines 4-9) must refer to pg names, ports in docker-compose, params in config.py and sets up user & DB that are created during startup.


* nginx\default.conf
  - Line 2: Listen port. Must be set, corresponding to docker-compose oz-api-nginx port param & config.py
  - Lines 27,43,48: Service names in redirect. oz-api, oz-statistic. Change if container names are changed in docker-compose.yaml


* configs\pg-o2n\init.sql
  - Username, DB name, password that are precreated in DB.
  - Username lines 1, 9
  - Password line 1
  - DB name lines 8, 16


* configs\postgres\init.sql
  - Username, DB name, password that are precreated in DB.
  - Username lines 1, 9
  - Password line 1
  - DB name lines 8, 16


* configs\redis\redis.conf
  - Line 2: password for security. Refers to config.py
  - Line 4: Port. Refers to config.py


* data\tfss
  - Must have 'models', 'updater' and 'tmp' folders for download and save models.


* configs\webui\aquireToken.sh
  - Line 3-6: API params. WebUI should point to oz-api-nginx container. Set name and port as used for oz-api-nginx.
  - Line 5-6: Login and password must be same as in configs\init\init-user.sh (You may use other creds if manually created another user)


* configs\o2n\config.env
  - Lines 6-10: pg-o2n params. Must be same as set in init-o2n.sh and pg-o2n\init.sql
  - Line 12: Password for superuser in PG O2N.
  - Lines 14-16: Service params for superuser in PG.
  - Lines 24-29: DB params. Must be set same as in configs\postgres\init.sql
  - Line 38: 'APP_ENV' User 'local' for http, 'https' for https.
  - Line 51-57: Mail params. Set up for 'send password to email' option.

* configs\config.env
  - Lines 59-72: TFSS Updater and TFSS initer params.

* configs\websdk\app_config.json
  - Line 4: Enables or not access to the /debug.php page, which contains information about the current configuration and the current license.
  - Line 5: Set host Oz API IP address and port number. Allowed to use DNS to specify address host with Oz API.
  - Line 6: A WebSDK require service account token on Oz API for correct deployment. Precreate user for WebSDK with type CLIENT and 'is_service' flag set. Put this access token here. More information about [User Roles](https://doc.ozforensics.com/oz-knowledge/guides/developer-guide/api/oz-api/user-roles). 
  - Line 51: Set the parameter that specifies the contents of the server response with verification results.  [Examples of values](https://doc.ozforensics.com/oz-knowledge/guides/developer-guide/sdk/oz-liveness-websdk/web-plugin/launching-the-plugin/description-of-the-on_complete-callback#full).
  - Information about other settings [WebSDK configiration](https://doc.ozforensics.com/oz-knowledge/guides/administrator-guide/web-adapter/configuration-file-settings).  

## Usage

### Docker All-In-One

This configuration involves running all services on a single host.

```commandline
docker compose --env-file configs/config.env -f docker-compose-all.yml up -d
```

### Docker Separated

This configuration involves running the tfss service and the api service on different hosts.

TFSS host

```commandline
docker compose --env-file configs/config.env -f docker-compose-bio.yml up -d
```

API host

```commandline
docker compose --env-file configs/config.env -f docker-compose-api.yml up -d
```

### Podman

```commandline
podman-compose --env-file configs/config.env -f docker-compose-separated.yml up -d
```

## Monitoring

Access the metrics using the following paths:

| Service  | Path                         |
|----------|------------------------------|
| TFSS     | :8501/metrics/tfss           |
| Celery   | :5555/metrics/flower/metrics |
| Redis    | :9117/metrics/redis          |
| Postgres | :9187/metrics                |
| Nginx    | :9113/metrics/nginx          |

## Stop services

### Docker

```commandline
docker compose --env-file configs/config.env -f docker-compose-separated.yml down
```

### Podman

```commandline
podman-compose --env-file configs/config.env -f docker-compose-separated.yml down
```

## Hints:
  * All DBs are precreated with init-* containers. To recreate DB, delete db folders in data\postgres & pg-o2n folders. Refer to configs section for configs reference.
  * To enable TFSS, uncomment oz-tfss section in docker-compose.yaml, lines 323-338. To use external TFSS change configs\api\config.py. Must have license and models in place for operations. Refer to configs section for configs and data reference.
  * To use TFSS server balancing, use service bioloadbalancer in docker-compose-bio.yaml and the nginx configuration example configs\nginx\bioloadbalancer.conf. Default service is not used. 

## Additional resources

https://apidoc.ozforensics.com/ - REST API documentation 

