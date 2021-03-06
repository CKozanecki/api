# our base build image
FROM maven:3.6-jdk-8 as build

# copy the project files
COPY ./pom.xml ./pom.xml

# build all dependencies
RUN mvn dependency:go-offline -B

# copy your other files
COPY ./src ./src

# build for release
RUN mvn package


FROM openjdk:8-jre

VOLUME ["/hygieia/logs"]

RUN mkdir -p /hygieia/config

EXPOSE 8080

ENV PROP_FILE /hygieia/config/application.properties

WORKDIR /hygieia

COPY --from=build target/*.jar ./ 
COPY docker/properties-builder.sh properties-builder.sh

CMD bash ./properties-builder.sh && java -Djava.security.egd=file:/dev/./urandom -jar *.jar --spring.config.location=$PROP_FILE