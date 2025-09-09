module Ui.ProblemContent exposing (view)

import Html exposing (Html, div, h1, p, text)
import Html.Attributes as A
import Types exposing (ProblemDetail)


view : ProblemDetail -> Html msg
view detail =
    div [ A.class "p-3 grid gap-6" ]
        [ h1 [ A.class "text-3xl font-extrabold uppercase tracking-wide" ] [ text detail.title ]
        , p [ A.class "whitespace-pre-wrap text-xl leading-8" ] [ text detail.questionMd ]
        ]
