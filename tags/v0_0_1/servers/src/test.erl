-module(test).
-compile(export_all).

-define(MAP1, 
        {-1, -2, -4, -5, -6, -5, -4, -2, -1, 
         0, 0, 0, 0, 0, 0, 0, 0, 0, 
         0, -3, 0, 0, 0, 0, 0, -3, 0, 
         -7, 0, -7, 0, -7, 0, -7, 0, -7, 
         0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,
         7,0,7,0,7,0,7,0,7, 
         0,3,0,0,0,0,0,3,0,
         0,0,0,0,0,0,0,0,0,
         1,2,4,5,6,5,4,2,1}
       ).
test_rules() -> 
    io:format("~p~n", [rules:get_list_all(?MAP1, -1)]).

test_apply() ->
    printMap(chessmap:apply(?MAP1, {{0, 0}, {1, 0}})).
    
test_key_erver() ->
    judgment_keyserver:start_link(),
    gen_server:call(judgment_keyserver, {try_add, {test, test2}}).
    
test_value() ->
    wigth:start_link(ai_god),
    value:get_value(?MAP1, 1).

test_rpc() ->
    A = rpc:call(t1@hantuo, test, test_rpc, [1, 2]),
    B = rpc:call(t2@hantuo, test, test_rpc, [3, 4]),
    {A, B}.
test_rpc(A, B) ->
    A + B.
test_ai(N) ->
    test_ai(N, ?MAP1, 1).
test_ai(0, Map, _Flag) -> printMap(Map);
test_ai(N, Map, Flag) ->
    printMap(Map),
    {M, _} = ai_comput:comput(Map, Flag, 2),
    io:format("~p~n", [M]),
    test_ai(N - 1, chessmap:apply(Map, M), -Flag).
    
    
test_ai_get() ->
    ai:get(a, "flag=2&map=" ++ binary_to_list(chessmap:pack(tuple_to_list(?MAP1)))).
test_web(_E, I) -> 
     io:format("~p~n", [httpd:parse_query(I)]).

    
printMap(Map) ->
    printMap(Map, 1).
printMap(_Map, 91) -> io:format("~n");
printMap(Map, N) ->
    if 
        element(N, Map) >= 0 -> io:format(" ");
        true -> void
    end,
    io:format("~p  ", [element(N, Map)]),
    if
        N rem 9 =:=  0 -> io:format("~n");
        true -> void
    end,
    printMap(Map, N + 1).
    

