-module(start).
-export([boot/0, boot/1]).


boot() ->
boot(true).
boot(false) ->
compile();
boot(true) ->
mysql_start(),
compile().

mysql_start() -> 
erlydb:start(mysql, [{hostname, "localhost"}, {username, "root"}, {password, "admin"}, {database, "regsysdb"}]).

compile() -> 
erlyweb:compile("f:/regsysapp",[{erlydb_driver, mysql}]).