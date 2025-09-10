module Ui.Table exposing (baseTableAttrs, col, td, tdCenterText)

import Html exposing (Html, node, span, text)
import Html.Attributes as A


baseTableAttrs : { label : String, cols : Int, rows : Maybe Int } -> List (Html.Attribute msg)
baseTableAttrs meta =
    [ A.class "w-full table-fixed border-separate border-spacing-0 m-0"
    , A.attribute "role" "grid"
    , A.attribute "aria-colcount" (String.fromInt meta.cols)
    , A.attribute "aria-label" meta.label
    ]
        ++ (case meta.rows of
                Just r ->
                    [ A.attribute "aria-rowcount" (String.fromInt r) ]

                Nothing ->
                    []
           )


col : Float -> Html msg
col pct =
    node "col" [ A.attribute "style" ("width:" ++ String.fromFloat pct ++ "%") ] []


td : List (Html msg) -> Html msg
td children =
    Html.td [ A.class "h-16 px-6 py-0 border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center text-2xl" ] children ]


tdCenterText : String -> Html msg
tdCenterText s =
    Html.td [ A.class "h-16 px-6 py-0 text-center border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center justify-center text-2xl" ] [ text s ] ]
