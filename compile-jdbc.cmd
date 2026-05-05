@echo off
setlocal enabledelayedexpansion

set "JAVA_HOME=C:\Users\Windows\AppData\Roaming\Code\User\globalStorage\pleiades.java-extension-pack-jdk\java\21\bin\.."
set "M2_HOME=C:\Users\Windows\.maven\maven-3.9.15"
set "PATH=!M2_HOME!\bin;!JAVA_HOME!\bin;!PATH!"

cd /d "d:\Resume_to_Portfolio Builder"

echo Compiling Java and JDBC Implementation with Java 21...
call "!M2_HOME!\bin\mvn.cmd" clean compile

if errorlevel 1 (
    echo Compilation failed
    exit /b 1
)

echo.
echo Compilation successful - Java and JDBC implementation verified
