-module(jSURI@foreign).

-export(['_decodeURIComponent'/0, '_encodeURIComponent'/0, '_encodeFormURLComponent'/0, '_decodeFormURLComponent'/0]).

encdecURI(EncDec) ->
  fun (Fail, Succ, S) ->
    try
      Succ(EncDec(S))
    catch
      _:_ -> Fail("Couldn't encode/decode URI")
    end
  end.


toRFC3896(Input) ->
  lists:foldl(fun (Char, S) ->
      Replacement = unicode:characters_to_binary(io_lib:format("%~2..0B", [Char]), utf8),
      binary:replace(S, <<Char>>, Replacement, [global])
    end,
  Input,
  "!'()*"
  ).

%% http_uri:encode/decode are almost matching JS (encode/decode)UriComponent
'_encodeURIComponent'() -> encdecURI(fun (S) -> toRFC3896(http_uri:encode(S)) end).
'_decodeURIComponent'() -> encdecURI(fun http_uri:decode/1).

'_encodeFormURLComponent'() -> encdecURI(fun (S) -> 
    binary:replace(toRFC3896(http_uri:encode(S)), <<"%20">>, <<"+">>, [global])
  end).
'_decodeFormURLComponent'() -> encdecURI(fun (S) ->
    http_uri:decode(binary:replace(S, <<"+">>, <<"%20">>, [global]))
  end).