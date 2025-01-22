@echo off
setlocal

rem Define the replacement version
set REPLACEMENT_VERSION="^5.6.0"

@echo Copying package.json to package.tmp.json
copy package.json package.tmp.json

@echo Replacing all occurrences of "workspace:*" with %REPLACEMENT_VERSION% in package.json
powershell -Command "(Get-Content package.json) -replace '\"workspace:\*\"', '\"%REPLACEMENT_VERSION%\"' | Set-Content package.json"

@echo Running yarn pack
cmd /c yarn pack

@echo Removing package.json and renaming package.tmp.json to package.json
del package.json
rename package.tmp.json package.json

@echo Generating a unique directory name using timestamp
for /f "tokens=1-3 delims=/- " %%a in ("%date%") do set DATE=%%c-%%b-%%a
for /f "tokens=1-3 delims=:.," %%a in ("%time%") do set TIME=%%a-%%b-%%c
set "TIMESTAMP=%DATE%T%TIME%"
set "TIMESTAMP=%TIMESTAMP: =0%"

set TEMP_DIR=%TEMP%\group-sort-strapi-plugin-%TIMESTAMP%
@echo Creating the temp directory at %TEMP_DIR%
mkdir %TEMP_DIR%

@echo Moving package.tgz to the temp directory
move package.tgz %TEMP_DIR%

@echo Running npm publish from the temp directory
cmd /c "cd %TEMP_DIR% && npm publish package.tgz"

@echo Done

rem Prevent the command prompt window from closing
pause