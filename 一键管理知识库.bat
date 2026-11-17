@echo off
setlocal enabledelayedexpansion
title 我的技术知识库 - 一键管理
cd /d "%~dp0"

:menu
cls
echo ==================================================
echo              我的技术知识库  -  一键管理
echo ==================================================
echo.
echo    [1]  本地预览    启动 docsify 并打开浏览器
echo    [2]  发布上线    提交改动并推送到 GitHub
echo    [3]  打开网站    访问线上知识库
echo    [4]  当前状态    查看提交记录与同步状态
echo    [0]  退出
echo.
set "choice="
set /p choice=请输入数字后回车:

if "%choice%"=="1" goto preview
if "%choice%"=="2" goto deploy
if "%choice%"=="3" goto openSite
if "%choice%"=="4" goto status
if "%choice%"=="0" goto end
goto menu

:preview
cls
echo 正在检测可用端口...
set "PORT=3000"
:findport
netstat -ano | findstr "LISTENING" | findstr ":!PORT! " >nul
if not errorlevel 1 (
    set /a PORT+=1
    if !PORT! gtr 3020 goto portfail
    goto findport
)
echo.
echo    预览地址: http://localhost:!PORT!
echo    按 Ctrl+C 或关闭窗口可停止服务
echo.
start "" "http://localhost:!PORT!"
npx docsify-cli serve . --port !PORT!
echo.
pause
goto menu

:portfail
echo.
echo 端口 3000 到 3020 全部被占用，请先关闭其他服务。
pause
goto menu

:deploy
cls
echo === 当前改动 ===
git status --short
echo.
set "msg="
set /p msg=输入提交说明（直接回车用默认值）:
if "%msg%"=="" set "msg=update wiki"
echo.
echo === 正在提交 ===
git add .
git commit -m "%msg%"
if errorlevel 1 goto nothing
echo.
echo === 正在推送 ===
git push origin main
if errorlevel 1 goto pushfail
echo.
echo 发布完成，线上页面约 1 分钟后生效。
pause
goto menu

:nothing
echo.
echo 没有改动需要提交，或提交失败。
pause
goto menu

:pushfail
echo.
echo 推送失败，请检查网络连接或 GitHub 登录状态。
pause
goto menu

:openSite
start "" "https://ty550660.github.io/my_study_Knowledge/"
goto menu

:status
cls
echo === 最近提交 ===
git log --oneline -5
echo.
echo === 同步状态 ===
git status -sb
echo.
echo === 远程地址 ===
git remote -v
echo.
pause
goto menu

:end
endlocal
exit /b 0
