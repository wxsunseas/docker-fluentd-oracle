#mac docker buildx build --platform linux/x86_64 -t fluentd-ora .            
#其他 docker build -t fluent .
FROM fluent/fluentd:edge-debian

# Use root account to use apt
USER root

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  sed -i s@/deb.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list 

ENV ORACLE_HOME=/oracle_client/instantclient_12_2
ENV TNS_ADMIN=$ORACLE_HOME/network/admin
# ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
# NLS_LANG设置错误可能导致ORACLE数据库连接不上
ENV NLS_LANG=American_America.UTF8
ENV NLS_DATE_FORMAT="yyyy-mm-dd hh24:mi:ss"
ENV OCI_DIR=$ORACLE_HOME:$OCI_DIR
ENV LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
ENV PATH=$ORACLE_HOME:$PATH

ADD ./instantclient_12_2 /oracle_client/instantclient_12_2
ADD ./ora_conf /etc/ld.so.conf.d
ADD ./plugin /fluentd/plugins

RUN echo \
&& cd /oracle_client/instantclient_12_2\
&& ln -s libclntsh.so.12.1 libclntsh.so \
&& ln -s libocci.so.12.1 libocci.so

RUN buildDeps="sudo make gcc g++ libc-dev" \
 && apt-get update \
 && apt-get install -y libaio1 \
 && apt-get install -y --no-install-recommends $buildDeps
 
RUN gem sources -r https://rubygems.org/ -a https://gems.ruby-china.com/

RUN echo 
RUN gem install activerecord -v 6.1
RUN gem install activerecord-import

# 从本地安装fluent插件， 因为fluent-plugin-sql b不支持表名带$,所以修改了一个，本地插件需要 bundle install & gem build fluent-plugin-sql.gemspec 
# RUN cd /fluentd/plugins/fluent-plugin-sql/  && gem build fluent-plugin-sql.gemspec 
RUN cd /fluentd/plugins/fluent-plugin-sql-master/pkg/ && fluent-gem install --local fluent-plugin-sql-2.3.0.gem
ADD ./plugin/fluent-plugin-sql-master /usr/local/bundle/gems/fluent-plugin-sql-2.3.0

RUN sudo gem install fluent-plugin-mongo
#  && sudo gem install fluent-plugin-sql --no-document \
#  && sudo gem install rails \
RUN sudo gem install activerecord-oracle_enhanced-adapter 
RUN sudo gem install ruby-oci8 

RUN sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY ./conf/fluent.conf /fluentd/etc/
# COPY entrypoint.sh /bin/

USER fluent

ENTRYPOINT ["/bin/sh",  "-c", "fluentd -c /fluentd/etc/fluent.conf"]