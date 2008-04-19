-module(chessmap).
-compile(export_all).


position({X, Y}) ->
    Y * 9 + X + 1;
position(N) ->
    {(N - 1) rem 9, (N - 1) div 9}.
    
apply(Map, {{XFrom, YFrom}, {XTo, YTo}}) ->
    L = apply_list([], Map, element(position({XFrom, YFrom}), Map), {{XFrom, YFrom}, {XTo, YTo}}, 1),
    list_to_tuple(lists:reverse(L)).
    
apply_list(L, _Map, _Chess, {{_XFrom, _YFrom}, {_XTo, _YTo}}, 91) -> L;
apply_list(L, Map, Chess, {{XFrom, YFrom}, {XTo, YTo}}, N) -> 
    PosTo = position({XTo, YTo}),
    PosFrom = position({XFrom, YFrom}),
    case N of
        PosTo -> apply_list([Chess | L], Map, Chess, {{XFrom, YFrom}, {XTo, YTo}}, N + 1);
        PosFrom -> apply_list([0 | L], Map, Chess, {{XFrom, YFrom}, {XTo, YTo}}, N + 1);
        _Other -> apply_list([element(N, Map) | L], Map, Chess, {{XFrom, YFrom}, {XTo, YTo}}, N + 1)
    end.
    
    
conver(rche) ->
    1;
conver(rma) ->
    2;
conver(rpao) ->
    3;
conver(rxiang) ->
    4;
conver(rshi) ->
    5;
conver(rjiang) ->
    6;
conver(rzu) ->
    7;
conver(bche) ->
    -1;
conver(bma) ->
    -2;
conver(bpao) ->
    -3;
conver(bxiang) ->
    -4;
conver(bshi) ->
    -5;
conver(bjiang) ->
    -6;
conver(bzu) ->
    -7;
conver(1) ->
    rche;
conver(2) ->
    rma;
conver(3) ->
    rpao;
conver(4) ->
    rxiang;
conver(5) ->
    rshi;
conver(6) ->
    rjiang;
conver(7) ->
    rzu;
conver(-1) ->
    bche;
conver(-2) ->
    bma;
conver(-3) ->
    bpao;
conver(-4) ->
    bxiang;
conver(-5) ->
    bshi;
conver(-6) ->
    bjiang;
conver(-7) ->
    bzu.
    
pack(L) ->
    list_to_binary(pack_list(L, [])).
pack_list([], L) -> L;
pack_list([H | T], L) -> pack_list(T, L ++ binary_to_list(<<H:32>>)).
unpack(B) ->
    unpack_list(B, []).
unpack_list(<<>>, L) -> L;
unpack_list(B, L) -> 
    {B1, B2} = split_binary(B, 4),
    <<A:32/signed>> = B1,
    unpack_list(B2, L ++ [A]).
