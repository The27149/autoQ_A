@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul
echo Packaging AutoAsk...
echo Current directory: %CD%
echo.

set "VERSION=1.0.0"
set "OUTPUT=autoask-v%VERSION%-full.zip"

echo.
echo [Step 1] Creating temp directory...
if exist "release" (
    echo Removing existing release directory...
    rd /s /q "release"
)
echo Creating release directory...
mkdir "release"
if errorlevel 1 (
    echo ERROR: Failed to create release directory
    pause
    exit /b 1
)

echo.
echo [Step 2] Building TypeScript...
echo Running: npm run build
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed! Please check code errors.
    pause
    exit /b 1
)
echo Build completed successfully.

echo.
echo [Step 3] Copying files...
if exist "dist" (
    echo Copying dist directory...
    xcopy "dist" "release\dist\" /E /I /Y
) else (
    echo WARNING: dist directory not found
)
if exist "src" (
    echo Copying src directory...
    xcopy "src" "release\src\" /E /I /Y
) else (
    echo WARNING: src directory not found
)

echo Copying config files...
if exist "config.example.json" copy "config.example.json" "release\"
if exist "package.json" copy "package.json" "release\"
if exist "tsconfig.json" copy "tsconfig.json" "release\"
if exist "nodemon.json" copy "nodemon.json" "release\"
if exist "????.md" copy "????.md" "release\"
if exist ".gitignore" copy ".gitignore" "release\"
if exist "package.bat" copy "package.bat" "release\"

echo.
echo [Step 4] Removing sensitive config file...
if exist "release\config.json" (
    del "release\config.json"
    echo Removed config.json
)

echo.
echo [Step 5] Installing production dependencies only...
echo Current directory before pushd: %CD%
pushd release
echo Current directory after pushd: %CD%
echo Running: npm install --production
call npm install --production
if errorlevel 1 (
    echo ERROR: npm install failed
    popd
    pause
    exit /b 1
)
popd
echo Current directory after popd: %CD%

echo.
echo [Step 6] Creating archive...
if exist "%OUTPUT%" (
    echo Removing existing archive...
    del "%OUTPUT%"
)
echo Running: Compress-Archive
powershell -Command "Compress-Archive -Path 'release\*' -DestinationPath '%OUTPUT%' -Force"
if errorlevel 1 (
    echo ERROR: Failed to create archive
    pause
    exit /b 1
)

echo.
echo [Step 7] Cleaning temp directory...
rd /s /q "release"

echo.
echo ========================================
echo Package created successfully: %OUTPUT%
echo ========================================
echo.
echo User instructions:
echo 1. Extract %OUTPUT%
echo 2. Copy config.example.json to config.json and configure
echo 3. Run npm start
echo.
pause
