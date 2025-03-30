FROM gradle:8.13.0-jdk21 AS builder
WORKDIR /app
COPY ./ /app/
RUN gradle build

FROM openjdk:21-jdk-slim-bullseye AS final
ARG JAR_FILE=target/*.jar
COPY --from=builder /app/build/libs/twitter-1.2.jar app.jar
EXPOSE 9001
ENTRYPOINT ["java", "-jar", "app.jar"]