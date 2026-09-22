FROM jenkins/jenkins:2.568.3-jdk21

USER root

COPY ZscalerRootCA.pem /tmp/ZscalerRootCA.pem

RUN keytool -importcert \
    -file /tmp/ZscalerRootCA.pem \
    -alias zscaler \
    -cacerts \
    -storepass changeit \
    -noprompt

USER jenkins
