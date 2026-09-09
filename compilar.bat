@echo off
REM ============================================================================
REM  compilar.bat  -  Compila las clases Java del proyecto.
REM
REM  Uso:  doble clic, o  compilar.bat  desde la consola.
REM
REM  IMPORTANTE: se compila con --release 8 a proposito.
REM  Tomcat 8.5 traduce las JSP con ecj-4.6.3, un compilador de 2016 que solo
REM  sabe leer class files hasta Java 8. Si estas clases se compilaran con la
REM  version por defecto del JDK, las JSP que las importan fallarian con
REM  "Only a type can be imported ... resolves to a package".
REM ============================================================================

setlocal
cd /d "%~dp0"

set TOMCAT_LIB=C:\xampp\tomcat\lib
set CP=%TOMCAT_LIB%\servlet-api.jar;%TOMCAT_LIB%\jsp-api.jar;%TOMCAT_LIB%\mysql-connector-j-8.3.0.jar

echo.
echo === Limpiando clases anteriores ===
if exist "WEB-INF\classes\com" rmdir /s /q "WEB-INF\classes\com"
if not exist "WEB-INF\classes" mkdir "WEB-INF\classes"

echo === Buscando fuentes ===
dir /s /b src\*.java > "%TEMP%\fuentes_inmobiliaria.txt"

echo === Compilando (destino: Java 8) ===
javac --release 8 -encoding UTF-8 -nowarn -cp "%CP%" -d "WEB-INF\classes" @"%TEMP%\fuentes_inmobiliaria.txt"

if errorlevel 1 (
    echo.
    echo *** ERROR DE COMPILACION ***
    del "%TEMP%\fuentes_inmobiliaria.txt" 2>nul
    pause
    exit /b 1
)

del "%TEMP%\fuentes_inmobiliaria.txt" 2>nul

echo === Copiando db.properties al classpath ===
copy /y "src\db.properties" "WEB-INF\classes\db.properties" >nul

echo.
echo Compilacion correcta.
echo Abra http://localhost:8080/inmobiliaria/
echo.
endlocal
