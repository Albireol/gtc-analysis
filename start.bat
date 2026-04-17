@echo off
chcp 65001 >nul
title GTC Data Analysis

echo ========================================
echo   GTC Data Analysis GUI
echo ========================================
echo.

cd /d "%~dp0"

if exist "venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
) else (
    echo Virtual environment not found!
    echo Creating virtual environment...
    python -m venv venv
    call venv\Scripts\activate.bat
    echo Installing dependencies...
    pip install -r requirements.txt -q
)

echo.
echo Starting GTC Analysis GUI...
echo.

python main.py

if errorlevel 1 (
    echo.
    echo ========================================
    echo   Error occurred while running GUI
    echo ========================================
    echo.
    pause
)
