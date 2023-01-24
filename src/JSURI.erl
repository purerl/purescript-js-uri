-module(jSURI@foreign).

-export(['_decodeURIComponent'/0, '_encodeURIComponent'/0, '_encodeFormURLComponent'/0, '_decodeFormURLComponent'/0]).

encdecURI(EncDec) ->
  fun (Fail, Succ, S) ->
    try
      Succ(EncDec(S))
    catch
      Err -> 
        ErrorString = io_lib:format("~p", [Err]),
        Fail(io_lib:format("Couldn't encode/decode URI: ~p", [ErrorString]))
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

'_encodeURIComponent'() -> encdecURI(fun (S) -> toRFC3896(uri_string:quote(S)) end).
'_decodeURIComponent'() -> encdecURI(fun uri_string:unquote/1).

'_encodeFormURLComponent'() -> encdecURI(fun (S) -> 
    binary:replace(toRFC3896(uri_string:quote(S)), <<"%20">>, <<"+">>, [global])
  end).
'_decodeFormURLComponent'() -> encdecURI(fun (S) ->
    uri_string:unquote(binary:replace(S, <<"+">>, <<"%20">>, [global]))
  end).
