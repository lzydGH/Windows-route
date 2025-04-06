@echo off
setlocal EnableExtensions enabledelayedexpansion

:: 显示IPv4路由表
cls
echo 正在显示IPv4路由表...
route print -4
pause

:menu_loop
cls
echo  路由管理工具 by lzydGH
echo  ----------------------------
echo  1. 添加路由
echo  2. 删除路由
echo  3. 修改路由
echo  4. 查看完整路由表
echo  5. 退出
echo  ----------------------------
set /p choice=请输入选项（1/2/3/4/5）：
if "%choice%"=="1" goto option_1
if "%choice%"=="2" goto option_2
if "%choice%"=="3" goto option_3
if "%choice%"=="4" goto option_4
if "%choice%"=="5" exit /b 0
echo 输入错误，请输入1-5之间的数字
pause
goto menu_loop

:option_1
call :add_route
goto menu_loop

:option_2
call :delete_route
goto menu_loop

:option_3
call :modify_route
goto menu_loop

:option_4
cls
echo 显示完整路由表...
echo ----------------------------
route print
echo ----------------------------
pause
goto menu_loop

:add_route
cls
echo 添加路由
set /p dest_ip=请输入目标IP地址：
set /p mask=请输入子网掩码（默认：255.255.255.0）：
if "%mask%"=="" set mask=255.255.255.0
set /p gateway=请输入网关地址：
set /p metric=请输入优先级（默认：2）：
if "%metric%"=="" set metric=2
set /p routes="是否添加为永久路由？(Y/N) 默认：N："
set route_type=
set route_status=已添加临时路由

if /i "%routes%"=="Y" (
    set "route_type=-p"
    set "route_status=已添加为永久路由"
)

route %route_type% add "%dest_ip%" mask "%mask%" "%gateway%" metric %metric% >nul

if errorlevel 1 (
    echo 路由添加失败
    pause
) else (
    echo %route_status%
    pause
)
goto :eof

:delete_route
cls
echo 删除路由
set /p dest_ip=请输入要删除的目标IP地址：

if "%dest_ip%"=="" goto :eof

echo 正在检查路由...
route print | find "%dest_ip%" >nul
if errorlevel 1 (
    echo 未找到匹配路由
    pause
    goto :eof
)

set /p confirm=是否需要输入网关？(y/n):
if "%confirm%"=="y" (
    set /p gateway=请输入网关地址：
    set /p subnet_mask=请输入子网掩码（默认为255.255.255.0）：
    if "%subnet_mask%"=="" set subnet_mask=255.255.255.0

    route delete "%dest_ip%" mask "%subnet_mask%" "%gateway%" >nul
    if errorlevel 1 (
        echo 删除失败，请检查权限或目标IP
        pause
    ) else (
        echo 正在确认删除结果...
        route print | findstr /R "%dest_ip%.*%subnet_mask%.*%gateway%" >nul
        if errorlevel 1 (
            echo 删除成功
            pause
        ) else (
            echo 删除失败，路由仍然存在
            echo 请检查输入的网关地址和子网掩码是否正确
            pause
        )
    )
) else if "%confirm%"=="n" (
    route delete "%dest_ip%" >nul
    if errorlevel 1 (
        echo 删除失败，请检查权限或目标IP
        pause
    ) else (
        echo 正在确认删除结果...
        route print | find "%dest_ip%" >nul
        if errorlevel 1 (
            echo 删除成功
            pause
        ) else (
            echo 删除失败，路由仍然存在
            pause
        )
    )
) else (
    echo 无效输入，请输入 y 或 n
    pause
    goto :eof
)
goto :eof

:modify_route
cls
echo 修改路由
set /p dest_ip=请输入要修改的目标网络：

if "%dest_ip%"=="" goto :eof

echo 正在检查路由...
route print | find "%dest_ip%" >nul
if errorlevel 1 (
    echo 未找到匹配路由
    pause
    goto :eof
)

set /p new_mask=请输入新子网掩码（默认：255.255.255.0）：
if "%new_mask%"=="" set new_mask=255.255.255.0
set /p new_gateway=请输入新网关地址：
set /p new_metric=请输入新跃点数（默认：2）：
if "%new_metric%"=="" set new_metric=2

route change "%dest_ip%" mask "%new_mask%" "%new_gateway%" metric %new_metric% >nul

if errorlevel 1 (
    echo 修改失败，请检查参数或权限
    pause
) else (
    echo 修改成功
    echo 新的路由信息：
    route print | find "%dest_ip%"
    pause
)
goto :eof

:eof
exit /b 0
