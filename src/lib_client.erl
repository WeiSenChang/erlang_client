%% -*- coding: utf-8 -*-

-module(lib_client).

-include_lib("wx/include/wx.hrl").

-export([start/0,
         init/1, handle_info/2, handle_event/2, handle_call/3,
         code_change/3, terminate/2]).

-behaviour(wx_object).

-record(state, {win}).

start() ->
    wx_object:start_link(?MODULE, [], []).

%% Init is called in the new process.
init([]) ->
    wx:new(),
    Frame = wxFrame:new(wx:null(),
			?wxID_ANY,
			"Game Client",
			[{size, {600,400}}]),
    
    wxFrame:createStatusBar(Frame,[]),

    wxFrame:connect(Frame, close_window),

    ok = wxFrame:setStatusText(Frame, "Welcome!",[]),
    wxFrame:show(Frame),

    MenuBar = wxMenuBar:new(),
    wxFrame:setMenuBar (Frame, MenuBar),
    FileMn = wxMenu:new(),
    wxMenuBar:append (MenuBar, FileMn, "&File"),
    Quit = wxMenuItem:new ([{id,400},{text, "&Quit"}]),
    wxMenu:append (FileMn, Quit),

    HelpMn = wxMenu:new(),
    wxMenuBar:append (MenuBar, HelpMn, "&Help"),
    About = wxMenuItem:new ([{id,500},{text, "&About"}]),
    wxMenu:append (HelpMn, About),

    wxFrame:connect (Frame, command_menu_selected),
    {Frame, #state{win=Frame}}.


%% Handled as in normal gen_server callbacks
handle_info(Msg, State) ->
    io:format("Got Info ~p~n",[Msg]),
    {noreply,State}.

handle_call(Msg, _From, State) ->
    io:format("Got Call ~p~n",[Msg]),
    {reply,ok,State}.

%% Async Events are handled in handle_event as in handle_info
handle_event(#wx{id = 400, event=#wxCommand{type = command_menu_selected}}, State = #state{win=Frame}) ->
    close(Frame),
    {stop, normal, State};
handle_event(#wx{id = 500, event=#wxCommand{type = command_menu_selected}}, State = #state{win=Frame}) ->
    D = wxMessageDialog:new (Frame, "Let's talk."),
    wxMessageDialog:showModal(D),
    {noreply, State};
handle_event(#wx{id = 401, event=#wxCommand{type = command_menu_selected}}, State = #state{win=_Frame}) ->
    {noreply, State};
handle_event(#wx{event=#wxClose{}}, State = #state{win=Frame}) ->
    close(Frame),
    {stop, normal, State}.

code_change(_, _, State = #state{win=Frame}) ->
    close(Frame),
    {stop, not_yet_implemented, State}.

terminate(_Reason, _State) ->
    ok.

%%%%%%
close(Frame) ->
    wxWindow:destroy(Frame),
    main:stop().