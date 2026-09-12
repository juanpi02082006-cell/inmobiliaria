@echo off
REM ============================================================================
REM  ejecutar-pruebas.bat  -  Corre las pruebas unitarias del proyecto (HU-20).
REM
REM  Uso:  ejecutar-pruebas.bat  (requiere haber corrido antes compilar-pruebas.bat)
REM
REM  Las pruebas de la capa de datos (paquete com.inmobiliaria.dao) necesitan
REM  MySQL de XAMPP levantado con la base "inmobiliaria" ya creada (ver
REM  sql\01_esquema.sql y sql\02_datos.sql): usan la misma configuracion de
REM  db.properties que la aplicacion, asi que no hay nada nuevo que ajustar.
REM  Las de com.inmobiliaria.util no tocan la base de datos.
REM ============================================================================

setlocal
cd /d "%~dp0"

if not exist "build\test-classes" (
    echo.
    echo *** Falta compilar las pruebas. Corra primero compilar-pruebas.bat ***
    echo.
    exit /b 1
)

set TOMCAT_LIB=C:\xampp\tomcat\lib
set JUNIT_JAR=lib\junit-platform-console-standalone-6.1.3.jar
set CP=build\test-classes;WEB-INF\classes;%TOMCAT_LIB%\mysql-connector-j-8.3.0.jar

echo.
java -jar "%JUNIT_JAR%" execute --classpath "%CP%" --scan-classpath --details=tree

endlocal
