module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as P
import Url.Parser.Query as Q


type Route
    = Home
    | Course String
    | Problem String String


fromUrl : Url -> Route
fromUrl url =
    let
        qp =
            Q.map2 Tuple.pair
                (Q.string "course")
                (Q.string "problem")
    in
    case P.parse (P.query qp) url of
        Just ( Just cid, Just pid ) ->
            Problem cid pid

        Just ( Just cid, Nothing ) ->
            Course cid

        _ ->
            Home
