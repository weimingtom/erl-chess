-module(judgment).
-compile(export_all).
-import(chessmap).

start(Port) ->
    judgment_keyserver:start_link(judgment_keyserver),
    {ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 4}]),
    spawn(fun() -> listen(Listen) end).

listen(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun() -> listen(Listen) end),
    {ok, {{N1, N2, N3, N4}, Port}} = inet:peername(Socket),
    Str = list_to_atom(integer_to_list(N1) ++ integer_to_list(N2) ++ integer_to_list(N3) ++ integer_to_list(N4) ++ integer_to_list(Port)),
    judgment_clientholder:start_link(Str, Socket),
	loop(Socket, Str).

loop(Socket, Str) ->
    receive
        {tcp, Socket, Bin} ->
            gen_server:call(Str, {recv, Bin}),
            loop(Socket, Str);
        {tcp_closed, Socket} ->
            gen_server:call(Str, stop);
        Other ->
            io:format("~nOther : ~p~n", [Other]),
            loop(Socket, Str)
	end.