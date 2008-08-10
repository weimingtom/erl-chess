%% Author: hantuo
%% Created: Aug 6, 2008
%% Description: TODO: Add description to socket_wraper
-module(socket_wraper).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
start() ->
    {ok, Listen} = gen_tcp:listen(8006, [binary, {packet, 0}]),
    spawn(fun() -> listen(Listen) end).

listen(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun() -> listen(Listen) end),
    {ok, Socket1} = gen_tcp:connect("127.0.0.1", 8005, [binary, {packet, 0}]),
	loop(Socket, Socket1).

loop(Socket, Socket1) ->
    receive
        {tcp, Socket, Bin} ->
            case binary_to_list(Bin) of 
				"<policy-file-request/>\0" ->
                    ok = gen_tcp:send(Socket, list_to_binary("<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0"));
                _Other ->
        			gen_tcp:send(Socket1, Bin)
            end,
            loop(Socket, Socket1);
        {tcp_closed, Socket} ->
            gen_tcp:close(Socket1);
        {tcp, Socket1, Bin} ->
        	gen_tcp:send(Socket, Bin),
            loop(Socket, Socket1);
        {tcp_closed, Socket1} ->
            gen_tcp:close(Socket);
        Other ->
            io:format("~nOther : ~p~n", [Other]),
            loop(Socket, Socket1)
	end.

