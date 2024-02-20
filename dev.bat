@echo off

set cookie=client
set node=client@192.168.0.199

goto wait_input

:wait_input
    echo ===================
    echo make file:    make
    echo start app:    start
    echo stop app:     stop
    echo quit escript: quit
    echo gen proto:    proto
    echo ===================
    set /p var=input:
    if %var% == make goto make
    if %var% == start goto start
    if %var% == stop goto stop
    if %var% == quit goto quit
    if %var% == proto goto proto
    goto wait_input

:make
    set var=
    rd /s /q "./ebin"
    md "./ebin"
    erl -noshell -s make all -s init stop
    goto wait_input

:start
    set var=
    start werl -setcookie %cookie% -name %node% -pa ./ebin/ -s main
    goto wait_input

:stop
    set var=
    start werl -setcookie %cookie% -name stop_%node% -pa ./ebin/ -eval "rpc:call('%node%', main, stop, []), init:stop()"
    goto wait_input

:proto
    set var=
    escript ./src/proto/gpb_compile.erl
    goto wait_input

:quit
    set var=
    goto :eof