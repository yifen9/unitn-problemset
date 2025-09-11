module Ui.ContentBlock exposing (view)

import Html exposing (Html, div, h1)
import Html.Attributes as A


type alias Props msg =
    { title : Html msg
    , content : Html msg
    }


view : Props msg -> Html msg
view p =
    div [ A.class "grid gap-3 content-start justify-items-start" ]
        [ h1 [ A.class "text-4xl font-extrabold uppercase tracking-wide" ] [ p.title ]
        , p.content
        ]
