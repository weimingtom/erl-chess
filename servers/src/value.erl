-module(value).
-compile(export_all).

get_value(Map, Flag) -> 
    Value = gen_server:call(wigth, {get_value}),
    Is_mine = fun(X) -> is_mine(X, Flag) end,
    {Chess, Free, Attack, Defend} = get_value(Map, Is_mine, Value, {0, 0, 0, 0}, 1),
    Chess + Free  + Attack  + Defend.
    
get_value(_Map, _Is_mine, _Value, {Chess, Free, Attack, Defend}, 91) -> {Chess, Free, Attack, Defend};
get_value(Map, Is_mine, Value, {Chess, Free, Attack, Defend}, N) -> 
    C = element(N, Map),
    case Is_mine(C) of 
        false -> get_value(Map, Is_mine, Value, {Chess, Free, Attack, Defend}, N + 1);
        true ->
            Chess1 = Value(chessmap:conver(C), chess),
            {Free1, Attack1, Defend1} = free_attack_defend(rules:(chessmap:conver(C))(Map, chessmap:position(N)), Map, Is_mine, Value, {0, 0, 0}),
            get_value(Map, Is_mine, Value, {Chess + Chess1, Free + Free1, Attack + Attack1, Defend + Defend1}, N + 1)
    end.

free_attack_defend([], _Map, _Is_mine, _Value, {Free, Attack, Defend}) -> {Free, Attack, Defend};
free_attack_defend([{{XFrom, YFrom}, {XTo, YTo}} | T], Map, Is_mine, Value, {Free, Attack, Defend}) -> 
    CFrom = element(chessmap:position({XFrom, YFrom}), Map),
    CTo = element(chessmap:position({XTo, YTo}), Map),
    {Free1, Attack1, Defend1} = if 
        CTo =:= 0 -> {Value(chessmap:conver(CFrom), free), 0, 0};
        true -> case Is_mine(CTo) of
            true -> {0, 0, Value(chessmap:conver(CTo), defend)};
            false -> {0, Value(chessmap:conver(CTo), attack), 0}
        end
    end,
    free_attack_defend(T, Map, Is_mine, Value, {Free + Free1, Attack + Attack1, Defend + Defend1}).
        


is_mine(Chess, Flag) ->
    case Chess * Flag of 
        A when A > 0 -> true;
        A when A =< 0 -> false
    end.

