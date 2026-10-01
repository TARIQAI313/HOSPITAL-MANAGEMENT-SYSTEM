@echo off
title AuraCare HMS - Cloud APK Builder
color 0B
chcp 65001 >nul
cls

echo ===================================================================
echo           AuraCare HMS - Automated Cloud APK Builder
echo ===================================================================
echo.
echo  Target Repository:
echo  https://github.com/TARIQAI313/HOSPITAL-MANAGEMENT-SYSTEM.git
echo.
echo ===================================================================
echo.

set REPO_URL=https://github.com/TARIQAI313/HOSPITAL-MANAGEMENT-SYSTEM.git

echo [1/3] Setting up local Git repository...
cd /d "C:\Users\Laptop Valley\OneDrive\Desktop\HOSPITAL MANAGEMENT"

"C:\Users\Laptop Valley\MinGit\cmd\git.exe" remote remove origin >nul 2>&1
"C:\Users\Laptop Valley\MinGit\cmd\git.exe" remote add origin %REPO_URL%
"C:\Users\Laptop Valley\MinGit\cmd\git.exe" branch -M main

echo.
echo [2/3] Uploading source code to GitHub cloud builder...
echo (NOTE: If GitHub asks for your username/password or opens your browser,
echo please approve it to allow the upload.)
echo.

"C:\Users\Laptop Valley\MinGit\cmd\git.exe" push -u origin main

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ===================================================================
    echo [IMPORTANT] Upload requires GitHub authentication:
    echo Please enter your GitHub Username (TARIQAI313) and Personal Access Token (or password).
    echo ===================================================================
    pause
    exit /b
)

echo.
echo ===================================================================
echo [SUCCESS] Code uploaded successfully to TARIQAI313/HOSPITAL-MANAGEMENT-SYSTEM!
echo.
echo [3/3] GitHub Cloud is now building your APK automatically!
echo Opening GitHub Actions page in your browser...
echo ===================================================================

start https://github.com/TARIQAI313/HOSPITAL-MANAGEMENT-SYSTEM/actions

echo.
echo In 3-4 minutes, the build will complete with a green checkmark!
echo Click on "AuraCare-Hospital-Management-APK" to download your APK directly!
echo.
pause
