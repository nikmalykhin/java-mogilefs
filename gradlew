#!/usr/bin/env sh

# Gradle Wrapper Script - Unix/Linux/Mac (Simplified)
# For Gradle 7.6.0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_HOME="$SCRIPT_DIR"
APP_BASE_NAME="$(basename "$0")"

DEFAULT_JVM_OPTS="-Xmx64m -Xms64m"

warn() {
    echo "$*" >&2
}

die() {
    echo "$*" >&2
    exit 1
}

# Find Java
if [ -n "$JAVA_HOME" ]; then
    if [ -x "$JAVA_HOME/bin/java" ]; then
        JAVACMD="$JAVA_HOME/bin/java"
    else
        die "ERROR: JAVA_HOME points to an invalid Java installation: $JAVA_HOME"
    fi
else
    JAVACMD="java"
    command -v java >/dev/null 2>&1 || die "ERROR: JAVA_HOME not set and 'java' not in PATH"
fi

# Gradle wrapper jar
CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

# Execute Gradle
exec "$JAVACMD" $DEFAULT_JVM_OPTS -Dorg.gradle.appname="$APP_BASE_NAME" \
    -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
