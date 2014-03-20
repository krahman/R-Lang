-module(login_controller).
%-erlyweb_magic(erlyweb_controller).
-export([index/1]).

index(A) ->
    case yaws_arg:method(A) of
        'GET' ->
            {data, {"", []}};
        'POST' ->
            case erlyweb_forms:validate(A, ["username", "password"], fun validate_field/2) of
                {[Username, Password], []} ->
                    case app_user:find(
                           {'and',
                            [{username,'=',Username},
                             {password,'=',crypto:sha(Username ++ Password)}]}) of
                        [] ->
                            {data, {Username, [invalid_credentials]}};
                        [User] ->
                            Key = crypto:rand_bytes(20),
                            Encoded = base64:encode(binary_to_list(Key)),
                            app_user:save(app_user:key(User, Key)),
                            {response,
                             [yaws_api:setcookie("key", Encoded),
                              {ewr, main}]}
                    end;
                {[Username, _Password], Errors} ->
                    {data, {Username, Errors}}
            end
    end.
 
validate_field("username", Val) when length(Val) > 4 -> ok;
validate_field("username", _) -> {value_too_short, "username", "5"};
validate_field("password", Val) when length(Val) > 5 -> ok;
validate_field("password", _) -> {value_too_short, "password", "6"} .