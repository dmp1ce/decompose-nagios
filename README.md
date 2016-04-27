# Nagios Decompose environment

Environment intended to be used with the Decompose utility to easily start a new Nagios project.

# Requirements

- [decompose](https://github.com/dmp1ce/decompose)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://www.docker.com/docker-compose)

# Quick start

```bash
# Initialize environment
decompose --init https://github.com/dmp1ce/decompose-nagios.git
decompose build

# See nagios core and nagios cgi running
docker-compose ps

# Visit website (using port from docker-compose ps)
curl localhost:33333/nagios

# Modify configuration
vim containers/nagios/etc/nagios.cfg

# Add Telegram token in secret resources
vim containers/nagios/etc/secrets.cfg
```
