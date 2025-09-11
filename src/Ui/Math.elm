module Ui.Math exposing (block, inline)

import Html exposing (Html, node)
import Html.Attributes as A

inline : String -> Html msg
inline s =
    node "katex-host"
        [ A.attribute "data-content" s
        , A.attribute "data-mode" "inline"
        ]
        []

block : String -> Html msg
block s =
    node "katex-host"
        [ A.attribute "data-content" s
        , A.attribute "data-mode" "block"
        , A.attribute "data-block" ""
        , A.class "text-2xl leading-tight"
        ]
        []