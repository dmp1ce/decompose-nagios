FROM debian
MAINTAINER David Parrish <daveparrish@tutanota.com>

# Build and install nagios and plugins
RUN apt-get update -yq && apt-get install -yq --no-install-recommends \
    build-essential \
    ca-certificates \
    unzip \
    automake \
    autoconf \
    gettext \
    openssh-client \
    python \
    python-pip \
    git && \

  # Create nagios user. Use host group and user ids to match host volumes.
  groupadd -g {{PROJECT_HOST_GROUPID}} -o nagios && \
  useradd -m -u {{PROJECT_HOST_USERID}} -g nagios -s /bin/bash nagios && \

  # Install Nagios
  cd /opt && echo "Installing nagios..." && \
  git clone https://github.com/NagiosEnterprises/nagioscore.git && cd nagioscore && \
  ./configure && make all && make install install-config && \
  
  # Install Nagios plugins
  cd /opt && echo "Installing nagios plugins..." && \
  git clone https://github.com/monitoring-plugins/monitoring-plugins.git && \
  cd monitoring-plugins && \
  ./tools/setup && \
  ./configure --prefix=/usr/local/nagios \
    --with-nagios-user=nagios --with-nagios-group=nagios && \
  make && make install && \

  # Download nagios Telegram script
  git clone https://github.com/pommi/telegram_nagios.git /opt/telegram_nagios && \
  pip install twx.botapi && \

  # Clean up system from install
  apt-get autoremove -y && \
  apt-get clean -y && \
  rm -rvf /var/lib/apt/lists/* && \
  rm -rvf /var/tmp/* && \
  rm -rvf /tmp/*

# Copy files to container filesystem
COPY ./ /app

# vi: set tabstop=2 expandtab:
