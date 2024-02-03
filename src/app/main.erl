%% -*- coding: utf-8 -*-

-module(main).

%% API
-export([start/0, stop/0]).

start() ->
    config:load(),
    lib_client:start(),
    io:format("game client start~n").


stop() ->
    io:format("game client stop~n"),
    init:stop().