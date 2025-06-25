FROM maven:3.9.8-eclipse-temurin-21 AS build
WORKDIR /spring-boot-application
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests


FROM eclipse-temurin:21-jre-alpine
WORKDIR /spring-boot-application
COPY --from=build /spring-boot-application/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]