module Ui.ProblemContent exposing (view)

import Html exposing (Html, div, h1, span, text)
import Html.Attributes as A
import Types exposing (ProblemDetail, ProblemType(..))
import Ui.Math as Math


view : ProblemDetail -> Html msg
view detail =
    let
        tlabel =
            case detail.ptype of
                Single ->
                    "SINGLE"

                Multi ->
                    "MULTI"
    in
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ div [ A.class "h-16 px-6 grid grid-cols-2 items-center border-b-2 border-base-300/60" ]
            [ span [ A.class "text-lg font-semibold" ] [ text ("ID " ++ detail.id ++ " · " ++ detail.date) ]
            , span [ A.class "justify-self-end badge badge-outline" ] [ text tlabel ]
            ]
        , div [ A.class "p-6 grid gap-3 content-start justify-items-start" ]
            [ h1 [ A.class "text-4xl font-extrabold uppercase tracking-wide" ] [ text detail.title ]
            , span [ A.class "text-2xl leading-tight" ] [ Math.block detail.questionMd ]
            ]
        ]
