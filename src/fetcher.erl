-module(fetcher).

-export([uname/0, uptime/0]).

-nifs([{uname, 0}, {uptime, 0}]).

-on_load init/0.

init() ->
    erlang:load_nif(
        filename:join([code:priv_dir(shinyfetch), "libfetcher"]), 0).

uname() ->
    exit(nif_library_not_loaded).

uptime() ->
    exit(nif_library_not_loaded).
