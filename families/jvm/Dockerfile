# syntax=docker/dockerfile:1
# JDK 25 runs every JVM robot: the Java binding calls the core through the
# Foreign Function and Memory API. Kotlin, Scala and Clojure build on it.
FROM eclipse-temurin:25.0.5_8-jdk-noble AS jdk
RUN rm -rf /opt/java/openjdk/lib/src.zip /opt/java/openjdk/jmods /opt/java/openjdk/man

FROM base AS java
COPY --from=jdk /opt/java/openjdk /opt/jdk-25
RUN for tool in jar java javac javap; do ln -s "/opt/jdk-25/bin/$tool" "/usr/local/bin/$tool"; done \
 && java -version 2>&1 | grep -q '"25\.'

# The official compiler and the public kotlinx.serialization runtime. The
# starter uses JsonElement directly, so no compiler plugin is needed.
FROM java AS kotlin
ARG KOTLIN_VERSION=2.4.21
ARG KOTLIN_SERIALIZATION_VERSION=1.13.0
ARG KOTLIN_COMPILER_SHA256=7cc140e76daf416a0424a5557f99afd7ca89ebd463ea1101261e3e01c33e75cd
ARG KOTLIN_SERIALIZATION_CORE_SHA256=db2eb98f585a408970ce726af9dfbaccbdfe5df498ccd9dba9918d208974302d
ARG KOTLIN_SERIALIZATION_JSON_SHA256=389b0dd9b4b952db889c160a2478b1cbe54680804f5315756108389dbe9df251
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/* \
 && curl -fsSLo /tmp/kotlin.zip "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip" \
 && echo "${KOTLIN_COMPILER_SHA256}  /tmp/kotlin.zip" | sha256sum -c - \
 && mkdir -p /opt/kotlin /opt/kotlinx \
 && unzip -q /tmp/kotlin.zip -d /opt/kotlin \
 && ln -s /opt/kotlin/kotlinc/bin/kotlinc /usr/local/bin/kotlinc \
 && curl -fsSLo /opt/kotlinx/kotlinx-serialization-core-jvm.jar "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-core-jvm/${KOTLIN_SERIALIZATION_VERSION}/kotlinx-serialization-core-jvm-${KOTLIN_SERIALIZATION_VERSION}.jar" \
 && echo "${KOTLIN_SERIALIZATION_CORE_SHA256}  /opt/kotlinx/kotlinx-serialization-core-jvm.jar" | sha256sum -c - \
 && curl -fsSLo /opt/kotlinx/kotlinx-serialization-json-jvm.jar "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-json-jvm/${KOTLIN_SERIALIZATION_VERSION}/kotlinx-serialization-json-jvm-${KOTLIN_SERIALIZATION_VERSION}.jar" \
 && echo "${KOTLIN_SERIALIZATION_JSON_SHA256}  /opt/kotlinx/kotlinx-serialization-json-jvm.jar" | sha256sum -c - \
 && rm /tmp/kotlin.zip

# Ubuntu's Scala and Clojure depend on its JDK 21; /usr/local/bin comes
# first on PATH, so java, javac and jar are 25's, and so is the java that
# scalac starts.
FROM java AS scala
RUN apt-get update && apt-get install -y --no-install-recommends scala && rm -rf /var/lib/apt/lists/*

FROM java AS clojure
RUN apt-get update && apt-get install -y --no-install-recommends clojure libdata-json-clojure && rm -rf /var/lib/apt/lists/*
