@echo off
REM ============================================================================
REM  compilar-pruebas.bat  -  Compila las pruebas unitarias del proyecto (HU-20).
REM
REM  Uso:  compilar-pruebas.bat  (requiere haber corrido antes compilar.bat,
REM        para que WEB-INF\classes tenga las clases de la aplicacion)
REM
REM  A diferencia de compilar.bat, las pruebas SI se compilan con el
REM  compilador por defecto del JDK: nunca las traduce el ecj de Tomcat porque
REM  nunca se despliegan, asi que no hace falta bajarlas a --release 8.
REM ============================================================================

setlocal
cd /d "%~dp0"

if not exist "WEB-INF\classes\com" (
    echo.
    echo *** Falta compilar la aplicacion. Corra primero compilar.bat ***
    echo.
    exit /b 1
)

set TOMCAT_LIB=C:\xampp\tomcat\lib
set JUNIT_JAR=lib\junit-platform-console-standalone-6.1.3.jar
set CP=WEB-INF\classes;%TOMCAT_LIB%\mysql-connector-j-8.3.0.jar;%JUNIT_JAR%

echo.
echo === Limpiando pruebas compiladas anteriores ===
if exist "build\test-classes" rmdir /s /q "build\test-classes"
mkdir "build\test-classes"

echo === Buscando fuentes de prueba ===
dir /s /b test\*.java > "%TEMP%\fuentes_pruebas_inmobiliaria.txt"

echo === Compilando pruebas ===
javac -encoding UTF-8 -nowarn -cp "%CP%" -d "build\test-classes" @"%TEMP%\fuentes_pruebas_inmobiliaria.txt"

if errorlevel 1 (
    echo.
    echo *** ERROR DE COMPILACION ***
    del "%TEMP%\fuentes_pruebas_inmobiliaria.txt" 2>nul
    pause
    exit /b 1
)

del "%TEMP%\fuentes_pruebas_inmobiliaria.txt" 2>nul

echo.
echo Compilacion de pruebas correcta.
echo Corra ejecutar-pruebas.bat para correrlas.
echo.
endlocal
