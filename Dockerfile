FROM quay.io/quarkus/centos-quarkus-maven:19.2.1 AS build
COPY src /usr/app/src
COPY pom.xml /usr/app
WORKDIR /usr/app
RUN mvn clean package

FROM fabric8/java-alpine-openjdk8-jre
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV AB_ENABLED=jmx_exporter
COPY --from=build /usr/app/target/lib/* /deployments/lib/
COPY --from=build /usr/app/target/*-runner.jar /deployments/app.jar
EXPOSE 8080
RUN adduser -G root --no-create-home --disabled-password 1001 \
  && chown -R 1001 /deployments \
  && chmod -R "g+rwX" /deployments \
  && chown -R 1001:root /deployments
USER 1001
ENTRYPOINT [ "/deployments/run-java.sh" ]
