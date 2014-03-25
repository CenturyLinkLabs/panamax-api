FROM panamax/ruby

RUN apt-get install -y libsqlite3-dev

ADD . /var/app/panamax-api
RUN chmod +x /var/app/panamax-api/bin/start.sh

WORKDIR /var/app/panamax-api
CMD "/var/app/panamax-api/bin/start.sh"