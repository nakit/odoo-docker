# About this Repo

This is a fork of the official Odoo repository at https://github.com/odoo/docker, which includes the addons used by the odoo-magento connector from http://odoo-magento-connector.com/

## Requirements

This container requires a postgres container linked as `db` to run. For example:

```
docker run --name postgresdb --env POSTGRES_USER=odoo --env POSTGRES_PASSWORD=odoo --detach postgres
```

Note: changing `POSTGRES_USER` and `POSTGRES_PASSWORD` to something more secure is recommended.

## Building this container

```
docker build --tag nakit/odoo https://github.com/nakit/odoo-docker.git
```

## Starting this container

```
docker run --publish 8069:8069 --link postgresdb:db --detach nakit/odoo
```
