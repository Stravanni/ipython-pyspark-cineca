FROM cineca/hadoop:2.5.2
MAINTAINER www.hpc.cineca.it

USER root

# Spark
RUN curl -s http://www.eu.apache.org/dist/spark/spark-1.3.0/spark-1.3.0-bin-hadoop2.4.tgz | tar -xz -C /usr/local/
RUN cd /usr/local \
    && ln -s spark-1.3.0-bin-hadoop2.4 spark
RUN mkdir /usr/local/spark/yarn-remote-client
ADD yarn-remote-client /usr/local/spark/yarn-remote-client

RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put /usr/local/spark-1.3.0-bin-hadoop2.4/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV SPARK_JAR hdfs:///spark/spark-assembly-1.3.0-hadoop2.4.0.jar
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

RUN pip install pip --upgrade
RUN pip2.7 install ipython[notebook]
RUN pip2.7 install -U nltk
RUN pip2.7 install pandas

RUN mkdir /notebooks
VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888
CMD IPYTHON_OPTS="notebook --no-browser --ip=0.0.0.0 --port 8888" pyspark