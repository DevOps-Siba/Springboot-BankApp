    FROM maven:3.9.9-eclipse-temurin-17 AS builder

    WORKDIR /src

	COPY . /src

	RUN mvn clean install -DskipTests

	#===========stage 2===================
	FROM eclipse-temurin:17-jre-alpine
	WORKDIR /src
	COPY --from=builder /src/target/*.jar /src/target/bankapp.jar
	EXPOSE 8080
	CMD ["java", "-jar", "/src/target/bankapp.jar"]
	