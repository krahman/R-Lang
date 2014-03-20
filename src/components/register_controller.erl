-module(register_controller).
%-erlyweb_magic(erlyweb_controller).
-export([index/1]).

index(A) ->
    case yaws_arg:method(A) of
	'POST' ->
	    Params = yaws_api:parse_post(A),
	    {[Username, Email, Password, Password2], Errs} =
		erlyweb_forms:validate(
		  Params, ["username", "email", "password", "password2"],
		  fun erlyweb_forms:validate/2),
	    Errs1 = 
		if Password == Password2 ->
			Errs;
		   true ->
			Errs ++ [password_mismatch]
		end,
	    if Errs1 =/= [] ->
		    {data, {Username, Email, Errs1}};
	       true ->		    
		    Usr = register_usr(Username, Email, Password),
		    login_controller:do_login(Usr)
	    end;
	_ ->
	    {data, {[],[],[]}}
    end.

register_usr(Username, Email, Password) ->
    Usr = usr:new_with([{username, list_to_binary(Username)},
			{email, Email},			
			{password, crypto:sha(Username ++ Password)}]),
    usr:save(Usr).
