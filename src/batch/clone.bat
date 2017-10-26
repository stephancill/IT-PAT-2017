@echo off
setlocal EnableDelayedExpansion
set repo="git clone %~2 ."
set repo=%repo:"=%
cd %1

%repo%