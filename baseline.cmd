@echo off
setlocal enabledelayedexpansion

set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "M2_HOME=C:\Users\Windows\.maven\maven-3.9.15"
set "PATH=!M2_HOME!\bin;!JAVA_HOME!\bin;!PATH!"

cd /d "d:\Resume_to_Portfolio Builder"

echo Baseline Compilation with Java 17...
call "!M2_HOME!\bin\mvn.cmd" clean test-compile

if errorlevel 1 (
    echo Compilation failed
    exit /b 1
)

echo.
echo Baseline Tests with Java 17...
call "!M2_HOME!\bin\mvn.cmd" clean test

if errorlevel 1 (
    echo Tests failed
    exit /b 1
)

echo.
echo Baseline setup successful
