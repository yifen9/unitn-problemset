module Ui.Math exposing (inline)

import Html exposing (Html, node)
import Html.Attributes as A


inline : String -> Html msg
inline s =
    node "katex-host" [ A.attribute "data-content" s ] []
