FROM openjdk:21-jdk-slim-bullseye
ARG JAR_FILE=target/*.jar
COPY build/libs/ums-1.2.jar app.jar
EXPOSE 9000
ENTRYPOINT ["java", "-jar", "app.jar"]