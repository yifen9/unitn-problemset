module Ui.ProblemContent exposing (view)

import Html exposing (Html, div, h1, span, text)
import Html.Attributes as A
import Types exposing (ProblemDetail)
import Ui.Math as Math


view : ProblemDetail -> Html msg
view detail =
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ div [ A.class "h-16 px-6 flex items-center border-b-2 border-base-300/60" ]
            [ span [ A.class "text-lg font-semibold" ] [ text ("ID " ++ detail.id ++ " · " ++ detail.date) ] ]
        , div [ A.class "p-6 grid gap-3 content-start justify-items-start" ]
            [ h1 [ A.class "text-4xl font-extrabold uppercase tracking-wide" ] [ text detail.title ]
            , Html.span [ A.class "text-2xl leading-tight" ] [ Math.block detail.questionMd ]
            ]
        ]
