module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as P
import Url.Parser.Query as Q


type Route
    = Home
    | Course String (Maybe String)


fromUrl : Url -> Route
fromUrl url =
    case P.parse (P.query (Q.string "course")) url of
        Just (Just cid) ->
            Course cid url.fragment

        _ ->
            Home
