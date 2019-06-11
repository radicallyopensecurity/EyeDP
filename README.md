# EYEdP

EYEdP is a federating identity provider. It is designed to be very self-contained and with minimal dependencies to run, so that it's very easy to setup. It exposes the configuration necessary to implement a SAML Identity Provider, as well as supporting an Nginx auth_request endpoint that will evaluate group based permissions.

## Contents

- [Usage](#usage)
- [Development](#development)
- [Identity Provider](#identity-provider)
  + [OpenID Connect](#openid-connect)
  + [SAML](#saml)
  + [Nginx Auth Request](#nginx-auth-request)

## Usage

EYEdP is a fairly standard Rails application that expects a database connection. The easiest way to setup an instance of EYEdP is to use the pre-built Docker container and attach it to a postgres container. An example topology can be seen in the [docker-compose.yml](./docker-compose.yml) in the main repository.

Alternately, a normal Ruby on Rails environment can be used to setup EYEdP, such as Heroku, a normal virtual machine, or a dedicated machine. The only required setup to get the application running it to configure the database.yml with the necessary options to configure the PostgreSQL database. The easiest way to configure the database is to export a `DATABASE_URL` environment veriable to the Rails process. Before starting EYEdP for the first time, the administrator should ensure that they run `bin/setup` to ensure that the database is ready for use.

## Development

To run EYEdP in development, it is recommended to use docker-compose like:

```bash
docker-compose build
docker-compose run web bin/setup
docker-compose up
```

To run EYEdP in development, it is recommended to use [Hivemind](https://github.com/DarthSim/hivemind) or [Overmind](https://github.com/DarthSim/overmind) like:

- `overmind s -f Procfile.dev`
- `hivemind Procfile.dev`

This will start up a development web server as well as watching for changes requiring updates. To handle initial setup, you should run `bin/setup` to ensure that the database is fully setup and ready to test!

## Users and Groups

The basic model for users and groups in EYEdP is similar to the model of LDAP, where users can be members of many groups, and a group can be nested. In addition, there is the concept of permissions which are inherited by a user from their groups.

### Users

A User is an entity that can sign into the identity provider. They have an email, two factor authentication keys, etc. Through their membership in various groups, they can have many permissions associated.

### Groups

A Group is a named collection of Groups and Permissions.

### Permissions

A Permission is the name given to a capability for a group.


## Identity Provider

EYEdP supports many different authentication frameworks, allowing it to be integrated with many different service providers.

### OpenID Connect

OpenID Connect requires setting up the `issuer` and `signing_key`. The signing key can be generated via a command like `openssl genpkey -algorithm RSA -out key.pem -pkeyopt rsa_keygen_bits:2048`. The issuer should be the fully qualified domain name(FQDN) of the authentication server.

### SAML

Saml requires a few pieces of configuration, `certificate`, `key`, and `base`. Similarly to the issuer for OpenID Connect, `base` should be the FQDN of the authentication server. Generating SAML's key and certificate should look like: `openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -keyout myKey.key -out myCert.crt`. This will generate a key and certificate with an expiration of ten years. It is entirely possible to change this expiration time as well. 

### Nginx Auth Request

The Nginx Auth Request backend is a fairly basic, group membership based permission check that allows implementing access restriction to applications that may not have their own acess controls at the Nginx layer. To learn more about how to use it, an admin should peruse the [groups](#groups) section of the documentetion.
