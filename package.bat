@echo off
echo 正在打包 AutoAsk...

set "VERSION=1.0.0"
set "OUTPUT=autoask-v%VERSION%-full.zip"

echo.
echo 创建临时目录...
if exist "release" rd /s /q "release"
mkdir "release"

echo.
echo 复制文件...
xcopy "dist" "release\dist\" /E /I /Y >nul 2>&1
xcopy "src" "release\src\" /E /I /Y >nul 2>&1
xcopy "node_modules" "release\node_modules\" /E /I /Y >nul 2>&1
copy "config.example.json" "release\" >nul 2>&1
copy "package.json" "release\" >nul 2>&1
copy "package-lock.json" "release\" >nul 2>&1
copy "tsconfig.json" "release\" >nul 2>&1
copy "nodemon.json" "release\" >nul 2>&1
copy "使用说明.md" "release\" >nul 2>&1
copy ".gitignore" "release\" >nul 2>&1
copy "package.bat" "release\" >nul 2>&1

echo.
echo 删除敏感配置文件...
if exist "release\config.json" del "release\config.json"

echo.
echo 创建压缩包...
if exist "%OUTPUT%" del "%OUTPUT%"
powershell -Command "Compress-Archive -Path 'release\*' -DestinationPath '%OUTPUT%' -Force"

echo.
echo 清理临时目录...
rd /s /q "release"

echo.
echo 打包完成: %OUTPUT%
echo.
echo 用户使用步骤:
echo 1. 解压 %OUTPUT%
echo 2. 复制 config.example.json 为 config.json 并配置
echo 3. 运行 npm start
echo.
pause