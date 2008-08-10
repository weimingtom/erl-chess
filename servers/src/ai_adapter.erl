%% Author: Administrator
%% Created: 2008-4-6
%% Description: TODO: Add description to ai_adapter
-module(ai_adapter).
-compile(export_all).

start(Key, IP, Port, Flag, URL) -> 
	case gen_tcp:connect(IP, Port, [binary, {packet, 4}], 10 * 1000) of
    	{ok, Socket} -> 
            Flag1 = if
        		Flag =:= 2 -> 1;
           	 	Flag =:= 1 -> -1
        	end,
            gen_tcp:send(Socket, list_to_binary([0, 0, 0, Flag] ++ Key)), listen(Socket, Flag1, URL);
    	{error, Why} -> io:format("connect faild, cause : ~p~n", [Why])
    end.

listen(Socket, Flag, URL) -> 
    receive
        {tcp, Socket, Bin} ->
            Exit = deal(Socket, Bin, Flag, URL),
            case Exit of
                false -> listen(Socket, Flag, URL);
                _Other -> exit
            end;
        {tcp_closed, Socket} -> io:format("close~n", []);
        Other ->
            io:format("~nOther : ~p~n", [Other]),
            listen(Socket, Flag, URL)
	end.

deal(Socket, Bin, Flag, URL) ->  
    {Bin_h, Bin_t} = split_binary(Bin, 4),
    <<H:32>> = Bin_h,
    case H of
        1 -> 
            <<F:32>> = Bin_t,
            case F of 
                1 -> io:format("add key sess!~n", []), false;
                0 -> io:format("add key faild!~n", []), true
            end;
        2 -> 
            <<F:32>> = Bin_t,
            case F of 
                1 -> io:format("request key sess!~n", []), false;
                0 -> io:format("request key faild!~n", []), true
            end;
        3 ->
            {Bin_flag, Bin_map} = split_binary(Bin_t, 4),
            <<F:32>> = Bin_flag,
            Map = chessmap:unpack(Bin_map),
                 case F of 
                     0 -> false;
                     2 -> io:format("win~n"), true;
                     3 -> io:format("lost~n"), true;
                     1 ->
                        case http:request(URL ++ "?flag=" ++ integer_to_list(Flag) ++ "&map=" ++ chessmap:pack_list(Map, [])) of
                        {ok, {_, _, [XFrom, YFrom, XTo, YTo]}} ->
                            Binary = <<3:32, XFrom:32, YFrom:32, XTo:32, YTo:32>>,  
                            gen_tcp:send(Socket, Binary),
							false;
                        {error, Reason} -> io:format("http request faild by : ~p~n", [Reason]), false
                     	end
                 end
    end.
            