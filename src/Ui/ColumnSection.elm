module Ui.ColumnSection exposing (Props, view)

import Html exposing (Html, div)
import Html.Attributes as A


type alias Props msg =
    { topLeft : Html msg
    , topRight : Html msg
    , bottomLeft : Html msg
    , bottomRight : Html msg
    , body : Html msg
    }


view : Props msg -> Html msg
view p =
    div [ A.class "h-full grid grid-rows-[8rem_1fr]" ]
        [ div [ A.class "border-b-2 border-base-300/60" ]
            [ div [ A.class "h-16 grid grid-cols-2 items-center border-b-2 border-base-300/60" ]
                [ div [ A.class "h-16 flex items-center justify-center border-r-2 border-base-300/60 text-2xl font-bold uppercase tracking-wide" ] [ p.topLeft ]
                , div [ A.class "h-16 flex items-center justify-center text-2xl font-bold uppercase tracking-wide" ] [ p.topRight ]
                ]
            , div [ A.class "h-16 grid grid-cols-2 items-center" ]
                [ div [ A.class "h-16 flex items-center justify-center border-r-2 border-base-300/60 text-2xl" ] [ p.bottomLeft ]
                , div [ A.class "h-16 flex items-center justify-center text-2xl" ] [ p.bottomRight ]
                ]
            ]
        , div [ A.class "p-6 grid gap-4 content-start" ] [ p.body ]
        ]
