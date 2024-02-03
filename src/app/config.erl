%%--- coding:utf-8 ---

-module(config).

%% API
-export([
    load/0,
    server_hour/0,
    server_minute/0,
    tcp_port/0
]).

-define(CONFIG, game_client_config:get).

load() ->
    case file:consult("./src/app/game_client.config") of
        {ok, [List | _]} ->
            AppName = game_client,
            case lists:keyfind(AppName, 1, List) of
                {AppName, TermList} ->
                    term_to_beam("game_client_config", TermList);
                _ ->
                    erlang:throw({error, no_config})
            end;
        Reason ->
            erlang:throw({error, Reason})
    end.

%%%%%%%%%%%
server_hour() ->
    ?CONFIG(server_hour).

server_minute() ->
    ?CONFIG(server_minute).

tcp_port() ->
    ?CONFIG(tcp_port).


%%%%%%%%%%%%%%%%
term_to_beam(ModName, TermList) ->
    BodyStr = term_to_erl(TermList, []),
    Str =
        "-module(" ++ ModName ++ ").
    -export([all/0, get/1, get/2]).

    all() ->\r\n\t#{" ++ BodyStr ++ "\r\n\t}.

    get(Key) ->
        get(Key, undefined).

    get(Key, Def) ->
        All = all(),
        maps:get(Key, All, Def).",
    NewModName = ModName ++ ".erl",
    file:write_file(NewModName, unicode:characters_to_binary(Str)),
    {ok, Mod} = compile:file(NewModName),
    code:purge(Mod),
    code:load_file(Mod),
    file:delete(NewModName),
    {ok, Mod}.

term_to_erl([], StrList) ->
    string:join(StrList, ",\r\n\t\t");
term_to_erl([{Key, Val} | Tail], StrList) ->
    Str = to_list(Key) ++ " => " ++ to_list(Val),
    term_to_erl(Tail, [Str | StrList]).

to_list(Val) when is_list(Val) ->
    "\"" ++ Val ++ "\"";
to_list(Val) when is_integer(Val) ->
    integer_to_list(Val);
to_list(Val) when is_float(Val) ->
    float_to_list(Val);
to_list(Val) when is_atom(Val) ->
    atom_to_list(Val);
to_list(Val) when is_binary(Val) ->
    binary_to_list(Val);
to_list(Val) ->
    binary_to_list(term_to_binary(Val)).