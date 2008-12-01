-module(ai_comput).
-compile(export_all).


comput(Map, Flag, N) ->
    case N of
        0 -> comput_bottom(Map, Flag, N);
        _Other -> comput_normal(Map, Flag, N)
    end.
    
    
comput_normal(Map, Flag, N) ->
    L = rules:get_list_all(Map, Flag),
    Num = distribute(L, fun comput_normal_rpc/2, {self(), Map, Flag, N}),
    comput_normal_wait(Num, Flag, {err, -Flag * 10000000}).

comput_normal_rpc(L, {Self, Map, Flag, Deep}) -> 
    comput_normal_rpc(L, {Self, Map, Flag, Deep}, {err, -Flag * 10000000}).

comput_normal_rpc([], {Self, _Map, _Flag, _Deep}, {M, N}) -> Self ! {M, N};
comput_normal_rpc([H | T], {Self, Map, Flag, Deep}, {M, N}) -> 
    case gen_server:call(ai_serverlist, {get_server}) of
        null -> Self ! no_server;
        Server -> 
            case rpc:call(Server, ai_comput, comput, [chessmap:apply(Map, H), -Flag, Deep - 1]) of
                time_out -> Self ! time_out;
                {badrpc, Err} -> 
                    io:format("err is ~p~n", [Err]),
                    gen_server:call(ai_serverlist, {bad_server, Server}),
                    comput_normal_rpc([H | T], {Self, Map, Flag, Deep}, {M, N});
                {_, N1} ->
                   {M2, N2} =  if
                       (N1 - N) * Flag >= 0 -> {H, N1};
                       true -> {M, N}
                   end,
                comput_normal_rpc(T, {Self, Map, Flag, Deep}, {M2, N2}) 
            end
    end.

comput_normal_wait(0, _Flag, {M, N}) -> {M, N};
comput_normal_wait(Num, Flag, {M, N}) ->
    receive 
        time_out -> time_out;
        no_server -> no_server;
        {M1, N1} -> 
            {M2, N2} = if 
                (N1 - N) * Flag >= 0 -> {M1, N1};
                true -> {M, N}
            end,
        	comput_normal_wait(Num - 1, Flag, {M2, N2})
    after 60 * 1000 ->
        time_out
    end.


comput_bottom(Map, _Flag, _N) -> {null, value:get_value(Map, 1) - value:get_value(Map, -1)}.

distribute(L, Fun, Args) ->
    Num = gen_server:call(ai_serverlist, {get_num}),
    Len = length(L) div Num + 1,
    Num1 = distribute(L, Fun, Args, Len, Num),
	Num - Num1.
    

distribute([], _Fun, _Args, _Len, N) -> N;
distribute(L, Fun, Args, _Len,  0) ->
    spawn(fun() -> Fun(L, Args) end), 
    0;
distribute(L, Fun, Args, Len, N) ->    
    if 
        length(L) < Len -> 
            spawn(fun() -> Fun(L, Args) end),
            distribute([], Fun, Args, Len, N - 1);
        true -> 
            {L1, L2} = lists:split(Len, L),
            spawn(fun() -> Fun(L1, Args) end),
            distribute(L2, Fun, Args, Len, N - 1)
    end.
    
