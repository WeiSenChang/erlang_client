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
    process_flag(trap_exit, true),
    Frame = wxFrame:new(wx:null(),
        ?wxID_ANY, % window id
        "Game Client", % window title
        [{size, {800, 600}}]),
    wxFrame:connect(Frame, close_window),

    Splitter   = wxSplitterWindow:new(Frame, [{style, ?wxSP_NOBORDER}]),

    wxSplitterWindow:setSashGravity(Splitter,   1.0),

    Panel = wxPanel:new(Splitter),
    PanelSz    = wxStaticBoxSizer:new(?wxVERTICAL, Panel, [{label, "Login"}]),
    wxPanel:setSizer(Panel, PanelSz),

    wxSplitterWindow:splitVertically(Splitter, Panel, Panel,
        [{sashPosition,0}]),

    wxWindow:show(Frame),

    Obj = text_ctrl:start([{parent, Panel}]),

    wxSizer:add(PanelSz, Obj, [{proportion,1}, {flag, ?wxEXPAND}]),
    wxSizer:layout(PanelSz),

    %% The windows should be set up now, Reset Gravity so we get what we want
    wxSplitterWindow:setSashGravity(Splitter,   1.0),

    wxSplitterWindow:setMinimumPaneSize(Splitter, 1),

    wxToolTip:enable(true),
    wxToolTip:setDelay(500),

    {Frame, #state{win=Obj}}.


%% Handled as in normal gen_server callbacks
handle_info(Msg, State) ->
    io:format("Got Info ~p~n",[Msg]),
    {noreply,State}.

handle_call(Msg, _From, State) ->
    io:format("Got Call ~p~n",[Msg]),
    {reply,ok,State}.

%% Async Events are handled in handle_event as in handle_info
handle_event(#wx{event=#wxClose{}}, State = #state{win=Frame}) ->
    io:format("~p Closing window ~n",[self()]),
    ok = wxFrame:setStatusText(Frame, "Closing...",[]),
    wxWindow:destroy(Frame),
    {stop, normal, State}.

code_change(_, _, State) ->
    {stop, not_yet_implemented, State}.

terminate(_Reason, _State) ->
    ok.