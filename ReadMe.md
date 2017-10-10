# GLPI containerized

[GLPI](http://glpi-project.org/) in a container with additional fusioninventory plugin.

## Word of caution

DO NOT DEPLOY this as is into production!

Default logins / passwords are:

- MySQL root password is admin\*
- glpi/glpi for the administrator account
- tech/tech for the technician account
- normal/normal for the normal account
- post-only/postonly for the postonly account

If you plan to set up in production mode, change these passwords!

## Usage

### Test
The docker-compose.yml uses volumes to store data and an external network. Make sure you create the `webnet` network prior to running it. Images are refered to as `my/glpi` and `my/mariadb:10.2.9`.

The exposed port is `9000` and not the usual `80`.

To build the glpi container:

```bash
docker build -t 'my/glpi' .
```

To test glpi:

```bash
docker-compose up -d
```

Follow the installation instructions.

### Prod

The Dockerfile in the root directory is used for initial setup. It allows access to `install/install.php`. If you plan to make your glpi container public and you changed the pre configured image name, edit the Dockerfile in the `prod` folder and change the base image name (FROM field) to reflect your base glpi image name (the one you chose while building your image). It only deletes the `install/install.php` for security reasons. I guess you've tested already and assume you edited the docker-compose.yml file to use the proper base image name as well.

The VIRTUAL_HOST and LETSENCRYPT_* environment variables are usefull only if you plan to use [jwilder/docker-gen](https://github.com/jwilder/docker-gen) and [jrcs/letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) to automate reverse proxying and certificate generation. Replace the placeholders with your own values or just ignore it if you have a different setup.

The nginx template might be outdated, but you can download the latest one:

```bash
curl -o nginx.tmpl https://raw.githubusercontent.com/jwilder/docker-gen/master/templates/nginx.tmpl
```

A docker-compose.yml file is included as an example to test out reverse-proxying and certificate generation automation. Before using it blindly, I would suggest to check out the respective project's documentations.
