@echo off
title Git Push Action (With Custom Message)

echo Starting...
echo.

:: [1/3] Adding files
echo [1/3] Adding files...
call git add .
if %errorlevel% neq 0 (
    echo Error: Git add failed!
    pause
    exit /b 1
)
echo.

:: [2/3] Get Commit Message from User
echo [2/3] Please enter your commit message:
set /p COMMIT_MSG="> "

:: 检查用户是否输入了内容
if "%COMMIT_MSG%"=="" (
    %COMMIT_MSG%="推送博客"
)

echo.
echo Committing with message: "%COMMIT_MSG%"
call git commit -m "%COMMIT_MSG%"

:: 检查 commit 是否成功 (如果没有变化，git commit 会返回 1)
if %errorlevel% neq 0 (
    echo Note: No changes to commit or commit failed. Skipping push.
    pause
    exit /b 0
)
echo.

:: [3/3] Pushing to remote
echo [3/3] Pushing to remote...
call git push

echo.
echo Done!
echo Closing in 2 seconds...
timeout /t 2 /nobreak >nul