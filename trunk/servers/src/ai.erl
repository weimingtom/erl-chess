-module(ai).
-compile(export_all).

get(_E, I) -> 
    [{"flag", F}, {"map", M}] = httpd:parse_query(I),
    Flag = list_to_integer(F),
    Map = list_to_tuple(chessmap:unpack(list_to_binary(M))),
    io:format("f : ~p~nm : ~p~n", [Flag, Map]),
    io:format("r : ~p~n", [ai_comput:comput(Map, Flag - 1, 2)]),
    {{{XForm, YFrom}, {XTo, YTo}}, _V} = ai_comput:comput(Map, Flag - 1, 2),
    "Content-type: text/plain\r\n\r\n" ++ [XForm, YFrom, XTo, YTo].