# Mailarchive

Mailarchive is a tool basen on [Piler](https://bitbucket.org/jsuto/piler)
that is intended for archiving and displaying emails.

Background: With emails, one is almost always bound to a cloud provider or to local software solutions.
For archiving and backup, the EML format is suitable, which does not require a tool.
However, emails in EML format are difficult to view/search.
Mailarchive offers a solution for this.

## How It Works

Mailarchive uses a Docker container that runs a Piler instance and a database, and an import daemon that monitors inbox and outbox folders and imports new emails into them.

These emails are then displayed and made searchable by [Piler](https://bitbucket.org/jsuto/piler).

Since Piler is normally designed for multi-user operation and therefore only displays emails addressed to its own email address,
email archives with many different mail addresses and distribution lists are often filtered out.
To avoid this, the own email address is added to the "x-envelope-to" header of each email as an additional recipient.

The email address is prefixed with "x-envelope-to_" for received emails and "x-envelope-from_" for sent emails.

This way, all imported emails are assigned to the user.

## Usage

You simply have to checkout the repo, adapt the config and run the install script.

After that the archive is running and you can copy emails into your import folders.

They will be imported automatically, but it will take some time (see [FAQ](#faq)).
 
>**WARNING**: During the import, the mails are deleted from the import folder!

## Config


- MAIL_ADDRESS: Your email address that shall be used for login.
- USER_PASSWORD: The password you want to use.
- IMPORT_SENT: The folder of sent mails you want to import
- IMPORT_RECEIVED: The folder of received mails you want to import
- MAILARCHIVE_HOST: The host under which the mailarchive shall be reached
- SERVER_PORT: The port under which the mailarchive shall be reached
- SUBNET: The first three blocks of the docker network under which this container shall be hosted
- CONTAINER_NAME: The name of the docker container

## Login

After the installation, two users are created:

- admin@local
- your@email.address

For both accounts you can use the configured password.

## FAQ

### Is there a support for Multiuser?

Yes, you can simply install 2 containers and adapt the config.
 
### How long does the import takes?

This depends on the size of the archive. I've tested it with about 100.000 Mails and the import took about 2h.

>**NOTE**: After the import script has imported everything and the mails are shown in the admin interface, it takes about additional 30 minutes for indexing. During this, mails are not shown in the user interface.

### What is the MariaDB root password?

The MariaDB password is generated and can be found as environment variable 'MYSQL_PASSWORD'.
