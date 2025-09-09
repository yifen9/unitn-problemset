module Ui.ProblemContent exposing (view)

import Html exposing (Html, div, h1, node, span, text)
import Html.Attributes as A
import Types exposing (ProblemDetail)


view : ProblemDetail -> Html msg
view detail =
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ div [ A.class "h-16 px-6 flex items-center border-b-2 border-base-300/60" ]
            [ span [ A.class "text-lg font-semibold" ] [ text ("ID " ++ detail.id ++ " · " ++ detail.date) ] ]
        , div [ A.class "p-6 grid gap-3 content-start justify-items-start math-scope" ]
            [ h1 [ A.class "text-4xl font-extrabold uppercase tracking-wide" ] [ text detail.title ]
            , node "katex-host" [ A.attribute "data-content" detail.questionMd
    , A.class "block text-2xl leading-9"
    ]
    []
            ]
        ]
