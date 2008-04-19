-module(rules).
-compile(export_all).
-import(chessmap).

get_list(Map, Pos) ->
    {X, Y} = Pos,
    Chess = chessmap:conver(element(chessmap:position({X, Y}), Map)),
    L = rules:Chess(Map, {X, Y}),
    [{{XFrom, YFrom}, {XTo, YTo}} || {{XFrom, YFrom}, {XTo, YTo}} <- L, 
        element(chessmap:position({XFrom, YFrom}), Map) * element(chessmap:position({XTo, YTo}), Map) =< 0].
    
get_list_all(Map, Flag) ->
    get_list_all(Map, Flag, [], 1).
get_list_all(_Map, _Flag, L, 91) -> L;
get_list_all(Map, Flag, L, N) ->
    case element(N, Map) * Flag of 
        C when C > 0 -> get_list_all(Map, Flag, get_list(Map, chessmap:position(N)) ++ L, N + 1);
        _Other -> get_list_all(Map, Flag, L, N + 1)
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% che %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rche(Map, Pos) -> che(Map, Pos, 1).
bche(Map, Pos) ->  che(Map, Pos, -1).
che(Map, Pos, Flag) ->
    {X, Y} = Pos,
    L1 = che([], Map, {X, Y - 1}, Pos, Flag, fun({A, B})->{A, B - 1} end),
    L2 = che(L1, Map, {X, Y + 1}, Pos, Flag, fun({A, B})->{A, B + 1} end),
    L3 = che(L2, Map, {X - 1, Y}, Pos, Flag, fun({A, B})->{A - 1, B} end),
    che(L3, Map, {X + 1, Y}, Pos, Flag, fun({A, B})->{A + 1, B} end).
che(L, _Map, {X, Y}, _Pos, _Flag, _Step) when Y < 0; Y >= 10; X < 0; X >= 9 -> L;
che(L, Map, {X, Y}, Pos, Flag, Step) -> 
    case element(chessmap:position({X, Y}), Map) of
        Chess when Chess =:= 0 -> che([{Pos, {X, Y}} | L], Map, Step({X, Y}), Pos, Flag, Step);
        Chess when (Chess * Flag) /= 0 -> [{Pos, {X, Y}} | L]
    end.
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ma  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rma(Map, Pos) ->
    ma(Map, Pos, 1).
bma(Map, Pos) ->
    ma(Map, Pos, -1).
ma(Map, Pos, _Flag) ->
    {X1, Y1} = Pos,
    L = [1, -1, 2, -2],
    [{Pos, {X + X1, Y + Y1}} || X <- L, Y <- L, 
    abs(X) /= abs(Y),
    X1 + X >= 0, 
    X1 + X < 9, 
    Y1 + Y >= 0, 
    Y1 + Y < 10,
    element(chessmap:position({X1 + (X div 2), Y1 + (Y div 2)}), Map) =:= 0
    ].
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% pao %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rpao(Map, Pos) ->
    pao(Map, Pos, 1).
bpao(Map, Pos) ->
    pao(Map, Pos, -1).
pao(Map, Pos, Flag) ->
    {X, Y} = Pos,
    L1 = pao_move([], Map, {X, Y - 1}, Pos, Flag, fun({A, B})->{A, B - 1} end),
    L2 = pao_move(L1, Map, {X, Y + 1}, Pos, Flag, fun({A, B})->{A, B + 1} end),
    L3 = pao_move(L2, Map, {X - 1, Y}, Pos, Flag, fun({A, B})->{A - 1, B} end),
    pao_move(L3, Map, {X + 1, Y}, Pos, Flag, fun({A, B})->{A + 1, B} end).
pao_move(L, _Map, {X, Y}, _Pos, _Flag, _Step) when Y < 0; Y >= 10; X < 0; X >= 9 -> L;
pao_move(L, Map, {X, Y}, Pos, Flag, Step) ->
    case element(chessmap:position({X, Y}), Map) of
        Chess when Chess =:= 0 -> pao_move([{Pos, {X, Y}} | L], Map, Step({X, Y}), Pos, Flag, Step);
        Chess when Chess /= 0 -> pao_kill(L, Map, Step({X, Y}), Pos, Flag, Step)
    end.
    
pao_kill(L, _Map, {X, Y}, _Pos, _Flag, _Step) when Y < 0; Y >= 10; X < 0; X >= 9 -> L;
pao_kill(L, Map, {X, Y}, Pos, Flag, Step) ->
    case element(chessmap:position({X, Y}), Map) of
        Chess when Chess =:= 0 -> pao_kill(L, Map, Step({X, Y}), Pos, Flag, Step);
        Chess when (Chess * Flag) /= 0 -> [{Pos, {X, Y}} | L]
    end.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% xiang %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rxiang(Map, Pos) ->
    xiang(Map, Pos, 1).
bxiang(Map, Pos) ->
    xiang(Map, Pos, -1).
xiang(Map, Pos, Flag) ->
    {X1, Y1} = Pos,
    Min = 
    if 
        Flag > 0 -> 5;
        Flag < 0 -> 0
    end,
    Max = 
    if 
        Flag > 0 -> 10;
        Flag < 0 -> 5
    end,
            
    L = [2, -2],
    [{Pos, {X + X1, Y + Y1}} || X <- L, Y <- L, 
    X1 + X >= 0, 
    X1 + X < 9, 
    Y1 + Y >= Min, 
    Y1 + Y < Max,
    element(chessmap:position({X1 + (X div 2), Y1 + (Y div 2)}), Map) =:= 0
    ].
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% shi %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rshi(Map, Pos) ->
    shi(Map, Pos, 1).
bshi(Map, Pos) ->
    shi(Map, Pos, -1).
shi(_Map, Pos, Flag) ->
    {X1, Y1} = Pos,
    Min = 
    if 
        Flag > 0 -> 7;
        Flag < 0 -> 0
    end,
    Max = 
    if 
        Flag > 0 -> 10;
        Flag < 0 -> 3
    end,
            
    L = [1, -1],
    [{Pos, {X + X1, Y + Y1}} || X <- L, Y <- L, 
    X1 + X >= 3, 
    X1 + X < 6, 
    Y1 + Y >= Min, 
    Y1 + Y < Max
    ].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% jiang %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rjiang(Map, Pos) ->
    jiang(Map, Pos, 1).
bjiang(Map, Pos) ->
    jiang(Map, Pos, -1).
jiang(Map, Pos, Flag) ->
    {X1, Y1} = Pos,
    Min = 
    if 
        Flag > 0 -> 7;
        Flag < 0 -> 0
    end,
    Max = 
    if 
        Flag > 0 -> 10;
        Flag < 0 -> 3
    end,
            
    L = [1, -1, 0],
    mingjiang(Map, 
    [{Pos, {X + X1, Y + Y1}} || X <- L, Y <- L,
    abs(X) /= abs(Y),
    X1 + X >= 3, 
    X1 + X < 6, 
    Y1 + Y >= Min, 
    Y1 + Y < Max
    ],
    {X1, Y1 - Flag},
    Pos,
    Flag).
mingjiang(_Map, L, {X, Y}, _Pos, _Flag) when Y < 0; Y >= 10; X < 0; X >= 9 -> L;
mingjiang(Map, L, {X, Y}, Pos, Flag) ->
    Chess1 = -element(chessmap:position(Pos), Map),
    case element(chessmap:position({X, Y}), Map) of
        Chess when Chess =:= Chess1 -> [{Pos, {X, Y}} | L];
        Chess when Chess /= 0 -> L;
        Chess when Chess =:= 0 -> mingjiang(Map, L, {X, Y - Flag}, Pos, Flag)
    end.
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% zu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rzu(Map, Pos) ->
    zu(Map, Pos, 1).
bzu(Map, Pos) ->
    zu(Map, Pos, -1).
zu(_Map, Pos, Flag) ->
    {X, Y} = Pos,
    Min = 
    if 
        Flag < 0 -> 5;
        Flag > 0 -> 0
    end,
    Max = 
    if 
        Flag < 0 -> 10;
        Flag > 0 -> 5
    end,
    Y1 = Y - Flag div abs(Flag), 
    L = 
    if 
        Y1 >= 0 -> [{Pos, {X, Y1}}];
        true -> []
    end, 
    L1 = 
    if 
        Y >= Min, Y < Max, X - 1 >= 0 -> 
            [{Pos, {X - 1, Y}} | L];
        true -> L
    end,
    if
        Y >= Min, Y < Max, X + 1 < 9 ->
            [{Pos, {X + 1, Y}} | L1];
        true -> L1
    end.
