@echo off
call ..\SETENV
echo Compiling...
for /f %%i in ('dir /b *.ASM') do (
	echo %%i-^>OUT\%%~ni.COM
	nasm %%i -o OUT\%%~ni.COM
	pause
)
