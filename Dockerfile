FROM centos:8

ARG ARG_AWS_S3_ACCESS_KEY_ID
ARG ARG_AWS_S3_SCRET_ACCESS_KEY
ARG ARG_AWS_S3_BUCKET
ARG ARG_AWS_S3_REGION
ARG ARG_AWS_S3_PATH

RUN yum update -y && \
  yum install -y glibc-langpack-ja && \
  cp /etc/localtime /etc/localtime.org && \
  ln -sf /usr/share/zoneinfo/Japan /etc/localtime #please change zone as needed

RUN yum install -y openssl openssl-devel readline readline-devel gcc vim ruby initscripts redhat-lsb.x86_64 gcc-c++

RUN echo -e "[treasuredata]\nname=TreasureData\nbaseurl=http://packages.treasuredata.com/3/redhat/8/\$basearch\ngpgcheck=0\ngpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent" > /etc/yum.repos.d/td.repo
RUN yum install -y td-agent
RUN setcap 'cap_net_bind_service=ep' /opt/td-agent/embedded/bin/ruby
RUN sed -i -e "s/User=td-agent/User=root/" -e "s/Group=td-agent/Group=root/" /usr/lib/systemd/system/td-agent.service
RUN sed -i -e "s/TD_AGENT_USER=td-agent/TD_AGENT_USER=root/" -e "s/TD_AGENT_GROUP=td-agent/TD_AGENT_GROUP=root/" /etc/init.d/td-agent

COPY td-agent.conf /etc/td-agent/

RUN usermod -u 1000 td-agent

RUN /usr/sbin/td-agent-gem install eventmachine fluent-plugin-s3
RUN chkconfig td-agent on

RUN sed -i -e "s|ARG_AWS_S3_ACCESS_KEY_ID|$ARG_AWS_S3_ACCESS_KEY_ID|g" -e "s|ARG_AWS_S3_SCRET_ACCESS_KEY|$ARG_AWS_S3_SCRET_ACCESS_KEY|g" -e "s|ARG_AWS_S3_REGION|$ARG_AWS_S3_REGION|g" -e "s|ARG_AWS_S3_BUCKET|$ARG_AWS_S3_BUCKET|g" -e "s|ARG_AWS_S3_PATH|$ARG_AWS_S3_PATH|g" /etc/td-agent/td-agent.conf

ENTRYPOINT ["/sbin/init"]

