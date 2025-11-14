# FROM eclipse-temurin:21-alpine
# COPY dockertest-0.0.1-SNAPSHOT.jar /dockertest-0.0.1-SNAPSHOT.jar
# EXPOSE 8100
# ENTRYPOINT ["java", "-jar", "/dockertest-0.0.1-SNAPSHOT.jar"]

# -------------------------------------------------------
# Stage 1: Build the JAR using Maven + JDK
# -------------------------------------------------------
FROM maven:3.9.4-eclipse-temurin-21-alpine AS build

# Set working directory
WORKDIR /app

# Copy Maven descriptor first
COPY pom.xml .

# Copy project source code
COPY src ./src

# Download dependencies
RUN mvn dependency:copy-dependencies

# Build the Spring Boot JAR (skip tests)
RUN mvn -X package -DskipTests

# -------------------------------------------------------
# Stage 2: Create lightweight runtime image
# -------------------------------------------------------
FROM eclipse-temurin:21-alpine

# Create working directory
WORKDIR /app

# Copy the built JAR from build stage to runtime stage
COPY --from=build /app/target/*.jar studentmarkservice.jar

# Expose application port (change only if your app uses a different port)
EXPOSE 8100

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "studentmarkservice.jar"]

