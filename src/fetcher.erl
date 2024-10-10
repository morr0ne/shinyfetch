-module(fetcher).

-export([uname/0]).

-nifs([{uname, 0}]).

-on_load init/0.

init() ->
    erlang:load_nif("priv/libfetcher", 0).

uname() ->
    exit(nif_library_not_loaded).
