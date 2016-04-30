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
    libcgi-pm-perl \
    librrds-perl \
    libgd-gd2-perl \
    libnagios-object-perl \
    apache2 \
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

  # Install nagiosgraph
  # https://sourceforge.net/p/nagiosgraph/git/ci/master/tree/README
  cd /opt && echo "Installing nagiosgraph..." && \
  git clone git://git.code.sf.net/p/nagiosgraph/git nagiosgraph-git && \
  cd nagiosgraph-git && \
  bash -c "mkdir -p /usr/local/nagiosgraph/{bin,cgi-bin,etc,share}" && \
  ls -alh /usr/local/nagiosgraph && \
  cp etc/* /usr/local/nagiosgraph/etc && \
  cp lib/insert.pl /usr/local/nagiosgraph/bin && \
  cp cgi/*.cgi /usr/local/nagiosgraph/cgi-bin && \
  cp share/nagiosgraph.css /usr/local/nagiosgraph/share && \
  cp share/nagiosgraph.js /usr/local/nagiosgraph/share && \
  cd /usr/local/nagiosgraph && \
  sed -i "s:use lib '/opt/nagiosgraph:use lib '/usr/local/nagiosgraph:g" cgi-bin/*.cgi && \
  sed -i "s:use lib '/opt/nagiosgraph:use lib '/usr/local/nagiosgraph:g" bin/insert.pl && \
  sed -i "s:logfile =.*:logfile = /usr/local/nagios/var/nagiosgraph.log:g" etc/nagiosgraph.conf && \
  sed -i "s:cgilogfile =.*:cgilogfile = /usr/local/nagios/var/nagiosgraph-cgi.log:g" etc/nagiosgraph.conf && \
  sed -i "s:perflog =.*:perflog = /usr/local/nagios/var/perfdata.log:g" etc/nagiosgraph.conf && \
  sed -i "s:rrddir =.*:rrddir = /usr/local/nagios/var/rrd:g" etc/nagiosgraph.conf && \
  sed -i "s:mapfile =.*:mapfile = /usr/local/nagiosgraph/etc/map:g" etc/nagiosgraph.conf && \
  bash -c "chown -R nagios: /usr/local/nagiosgraph/{bin,cgi-bin,etc,share}" && \

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
