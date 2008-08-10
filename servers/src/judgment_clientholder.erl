%%%-------------------------------------------------------------------
%%% File    : gen_server_template.full
%%% Author  : my name <yourname@localhost.localdomain>
%%% Description : 
%%%
%%% Created :  2 Mar 2007 by my name <yourname@localhost.localdomain>
%%%-------------------------------------------------------------------
-module(judgment_clientholder).

-behaviour(gen_server).

%% API
-export([start_link/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).


%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the server
%%--------------------------------------------------------------------
start_link(Name, Socket_self) ->
    gen_server:start_link({local, Name}, ?MODULE, [Name, Socket_self], []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
init([Name, Socket_self]) ->
    {ok, {Name, partner_name, Socket_self, key, turn}}.

%%--------------------------------------------------------------------
%% Function: %% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%%--------------------------------------------------------------------
handle_call({recv, Bin}, _From, {Name, Partner_name, Socket_self, Key, Turn}) ->
    io:format("~nBin is : ~p~n", [Bin]),
    {Bin_h, Bin_t} = split_binary(Bin, 4),
    <<H:32>> = Bin_h,
    case H of
        %% 客户端发来KEY
        1 -> Key1 = recv_key(Name, Socket_self, Bin_t, Key),
            {reply, ok, {Name, Partner_name, Socket_self, Key1, Turn}};
        %% 客户端请求连接某key
        2 -> {Name1, Key1, Turn1} = request_key(Name, Socket_self, Bin_t),
            {reply, ok, {Name, Name1, Socket_self, Key1, Turn1}};
        %% 客户端请求走一步棋
        3 -> Turn1 = request_move(Bin_t, Partner_name, Socket_self, Key, Turn),
            {reply, ok, {Name, Partner_name, Socket_self, Key, Turn1}};
        Other -> io:format("~nnet msg err,Other : ~p~n", [Other])
    end;
    

handle_call({get_name}, _From, {Name, Partner_name, Socket_self, Key, Turn}) ->
    {reply, Name, {Name, Partner_name, Socket_self, Key, Turn}};

handle_call({send, Bin}, _From, {Name, Partner_name, Socket_self, Key, Turn}) ->
    gen_tcp:send(Socket_self, Bin),
    {reply, ok, {Name, Partner_name, Socket_self, Key, Turn}};

handle_call({set_partner, Name}, _From, {Name1, _Partner_name, Socket_self, Key, Turn}) ->
    {reply, ok, {Name1, Name, Socket_self, Key, Turn}};
    
handle_call({set_key, Key}, _From, {Name, Partner_name, Socket_self, _Key, Turn}) ->
    {reply, ok, {Name, Partner_name, Socket_self, Key, Turn}};
    
handle_call({set_turn, Turn}, _From, {Name, Partner_name, Socket_self, Key, _Turn}) ->
    {reply, ok, {Name, Partner_name, Socket_self, Key, Turn}};

handle_call(stop, _From, {Name, Partner_name, Socket_self, Key, Turn}) ->
    case Turn of 
        true -> gen_server:call(list_to_atom(Key), stop),
        io:format("map server ~p closed!~n", [Key]);
        _Other -> void
    end,
    gen_server:call(judgment_keyserver, {try_del, {Key}}),
    io:format("player server ~p closed!~n", [Name]),
    {stop, normal, stopped, {Name, Partner_name, Socket_self, Key, Turn}};
    
handle_call(Request, _From, State) ->
    Reply = wrong_args,
    io:format("wrong_args : ~p~n", [Request]),
    {reply, Reply, State}.
    

%%--------------------------------------------------------------------
%% Function: handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% Description: Handling cast messages
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% Function: handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% Description: Handling all non call/cast messages
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% Function: terminate(Reason, State) -> void()
%% Description: This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% Func: code_change(OldVsn, State, Extra) -> {ok, NewState}
%% Description: Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------
recv_key(Name, Socket, Bin, Key) ->
    Key1 = "map_" ++ binary_to_list(Bin),
    case gen_server:call(judgment_keyserver, {try_add, {Key1, Name}}) of
        ok -> ok = gen_tcp:send(Socket, <<1:32, 1:32>>),
        Key1;
        _Other -> ok = gen_tcp:send(Socket, <<1:32, 0:32>>),
        Key
    end.
    
request_key(Name, Socket, Bin) ->
    Key = "map_" ++ binary_to_list(Bin),
    case gen_server:call(judgment_keyserver, {try_get, {Key}}) of
        key_not_exist -> ok = gen_tcp:send(Socket, <<2:32, 0:32>>),
            {partner_name, key, turn};
        Name1 -> 
            gen_server:call(Name1, {set_partner, Name}),
            gen_server:call(Name1, {set_key, Key}),
            gen_server:call(Name1, {set_turn, false}),
            ok = gen_server:call(judgment_keyserver, {try_del, {Key}}),
            ok = gen_tcp:send(Socket, <<2:32, 1:32>>),
            judgment_mapserver:start_link(list_to_atom(Key)),
            B1 = chessmap:pack([3] ++ [1] ++ tuple_to_list(gen_server:call(list_to_atom(Key), {get_map}))),
            B2 = chessmap:pack([3] ++ [0] ++ tuple_to_list(gen_server:call(list_to_atom(Key), {get_map}))),
            gen_tcp:send(Socket, B1),
            gen_server:call(Name1, {send, B2}),
            {Name1, Key, true}
    end.

request_move(Bin_t, Partner_name, Socket_self, Key, true) ->
    <<XFrom:32, YFrom:32, XTo:32, YTo:32>> = Bin_t,
    Map = gen_server:call(list_to_atom(Key), {get_map}),
    case gen_server:call(list_to_atom(Key), {try_move, {{XFrom, YFrom}, {XTo, YTo}}}) of
        true -> Map1 = gen_server:call(list_to_atom(Key), {get_map}),
                L1 = tuple_to_list(Map1),
                {T1, F1, F2} = case is_win(Map1, element(chessmap:position({XFrom, YFrom}), Map), {XTo, YTo}) of 
                    true -> gen_server:call(list_to_atom(Key), stop), {false, 2, 3};
                    _Other -> {true, 0, 1}
                end,
                B1 = chessmap:pack([3] ++ [F1] ++ L1),
                B2 = chessmap:pack([3] ++ [F2] ++ L1),
            gen_tcp:send(Socket_self, B1),
            gen_server:call(Partner_name, {send, B2}),
            gen_server:call(Partner_name, {set_turn, T1}),
            false;
        false -> true
    end;
request_move(_Bin_t, _Partner_name, _Socket_self, _Key, Turn) -> {Turn}.
    
is_win(Map, Flag, {_X, _Y}) ->
    Jiang = where_is_jiang(Map, -Flag),
    case Jiang of 
        null -> true;
        _Other -> is_siqi(Map, Flag)
    end.

where_is_jiang(Map, Flag) -> 
    {L, C} = if 
        Flag > 0 -> {[67,76,85,68,77,86,69,78,87], chessmap:conver(rjiang)};
        Flag < 0 -> {[4,13,22,5,14,23,6,15,24], chessmap:conver(bjiang)}
    end,
    case [N || N <- L, element(N, Map) =:= C] of 
        [N] -> N;
        _Other -> null
    end.
    
is_siqi(Map, Flag) ->
    %% 对方能下出的所有局面
    Maps1 = lists:map(fun(X) -> chessmap:apply(Map, X) end, rules:get_list_all(Map, -Flag)),
    case [M || M <- Maps1, can_kill_jiang(where_is_jiang(M, -Flag), rules:get_list_all(M, Flag)) =:= false] of 
        [] -> true;
        _Other -> false
    end.


can_kill_jiang(_Jiang, []) -> false;
can_kill_jiang(Jiang, [H | T]) ->
    {{_XFrom, _YFrom}, {XTo, YTo}} = H,
    case chessmap:position({XTo, YTo}) of 
        Jiang -> true;
        _Other -> can_kill_jiang(Jiang, T)
    end.

