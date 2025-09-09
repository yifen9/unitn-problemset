module Ui.ProblemTable exposing (view)

import Html exposing (Html, a, node, span, table, tbody, td, th, thead, tr, text)
import Html.Attributes as A
import Types exposing (Problem)

type alias Props =
    { problems : List Problem
    }

thc : String -> Html msg
thc label =
    th
        [ A.class "h-16 p-0 bg-base-200 border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "absolute inset-0 flex items-center justify-center text-2xl font-bold uppercase" ] [ text label ] ]

tdL : Html msg -> Html msg
tdL x =
    td [ A.class "h-16 px-6 py-0 border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center text-2xl" ] [ x ] ]

tdC : String -> Html msg
tdC s =
    td [ A.class "h-16 px-6 py-0 text-center border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center justify-center text-2xl" ] [ text s ] ]

view : Props -> Html msg
view props =
    let
        half = node "col" [ A.attribute "style" "width:75%" ] []
        rest = node "col" [ A.attribute "style" "width:25%" ] []
    in
    table
        [ A.class "w-full table-fixed border-separate border-spacing-0 m-0"
        , A.attribute "role" "grid"
        , A.attribute "aria-colcount" "2"
        ]
        [ node "colgroup" [] [ half, rest ]
        , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60 bg-base-100" ]
            [ tr [] [ thc "TITLE", thc "ID" ] ]
        , tbody []
            (List.map
                (\p ->
                    tr []
                        [ tdL (a [ A.href ("#p-" ++ p.id), A.class "link" ] [ text p.title ])
                        , tdC p.id
                        ]
                )
                props.problems
            )
        ]
