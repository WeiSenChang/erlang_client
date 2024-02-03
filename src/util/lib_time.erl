%% -*- coding: utf-8 -*-

-module(lib_time).

%% API
-export([
    to_date_time/1,

    minute_second/0,
    hour_second/0,
    day_second/0,

    next_min_time/1,
    next_hour_time/1,
    next_zero_time/1
]).

%% {Date, Time}, Date:{Year, Month, Day}, Time:{Hour, Minute, Second}
to_date_time(Tick) ->
    Hour = config:server_hour(),
    Minute = config:server_minute(),
    NewTick = Tick + Hour * hour_second() + Minute * minute_second(),
    calendar:gregorian_seconds_to_datetime(NewTick + calendar:datetime_to_gregorian_seconds(start_date_time())).

%% Second
next_min_time(Tick) ->
    {_, {_H, _M, S}} = to_date_time(Tick),
    minute_second() - S.

%% Second
next_hour_time(Tick) ->
    {_, {_H, M, S}} = to_date_time(Tick),
    hour_second() - M * minute_second() - S.

%% Second
next_zero_time(Tick) ->
    {_, {H, M, S}} = to_date_time(Tick),
    day_second() - H * hour_second() - M * minute_second() - S.

%% 内部接口
%%%%%%%%
start_date_time() ->
    {{1970, 1, 1}, {0, 0, 0}}.

minute_second() ->
    60.

hour_second() ->
    3600.

day_second() ->
    86400.