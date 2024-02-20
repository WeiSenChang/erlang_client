%% -*- coding: utf-8 -*-

-module(lib_cache).

-include("ets.hrl").

%% API
-export([
    get_frame_ref/0
]).

-export([
    set_frame_ref/1
]).

-define(CACHE_CTRL_REF, ctrl_pid).

get_frame_ref() ->
    get_cache(?CACHE_CTRL_REF, undefined).

set_frame_ref(CtrlRef) ->
    set_cache(?CACHE_CTRL_REF, CtrlRef).


%% 内部函数
get_cache(Key, Def) ->
    lib_ets:get(?ETS_GLOBAL_CACHE, Key, Def).

set_cache(Key, Value) ->
    lib_ets:set(?ETS_GLOBAL_CACHE, {Key, Value}).