FROM tribrhy/iactools:2.1

RUN mkdir /root/.ssh \
    && chmod 600 /root/.ssh \
    && echo "Host *" >  /root/.ssh/config \
    && echo "    StrictHostKeyChecking no" >>  /root/.ssh/config\
    && chmod 400 /root/.ssh/config
