FROM apache/spark:3.5.6

USER root
RUN wget -O /opt/spark/jars/spark-connect_2.12-3.5.6.jar \
    https://repo1.maven.org/maven2/org/apache/spark/spark-connect_2.12/3.5.6/spark-connect_2.12-3.5.6.jar

RUN mkdir -p /home/spark && \
    chown spark:spark /home/spark && \
    chmod 755 /home/spark

RUN mkdir -p /opt/spark/work/ivy_cache && \
    chown -R spark:spark /opt/spark/work/ivy_cache && \
    chmod -R 775 /opt/spark/work/ivy_cache

ENV SPARK_CONF_DIR=/mnt/spark-resources/conf
ENV HOME=/home/spark

USER spark

EXPOSE 15002

CMD [ \
    "/opt/spark/sbin/start-connect-server.sh", \
    "k8s://https://bettingaks.default.svc" \
    ]