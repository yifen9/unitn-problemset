module Ui.ProblemTable exposing (view)

import Html exposing (Html, a, div, i, node, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events as E
import Types exposing (Problem, ProblemSortBy(..))


type alias Props msg =
    { problems : List Problem
    , sortBy : ProblemSortBy
    , asc : Bool
    , onSort : ProblemSortBy -> msg
    }


ariaSort : ProblemSortBy -> Bool -> ProblemSortBy -> String
ariaSort current asc key =
    if key /= current then
        "none"

    else if asc then
        "ascending"

    else
        "descending"


thc : ProblemSortBy -> Bool -> String -> ProblemSortBy -> (ProblemSortBy -> msg) -> Html msg
thc current asc label key onSort =
    th
        [ A.class "h-16 p-0 bg-base-200 border-b-2 border-base-300/60 border-r-2 last:border-r-0"
        , A.attribute "role" "columnheader"
        , A.attribute "scope" "col"
        , A.attribute "aria-sort" (ariaSort current asc key)
        , E.onClick (onSort key)
        ]
        [ span [ A.class "relative inline-block w-full h-full" ]
            [ span [ A.class "absolute inset-0 flex items-center justify-center text-2xl font-bold uppercase" ] [ text label ]
            , if key == current then
                i
                    [ A.class
                        ("fa-solid absolute right-4 top-1/2 -translate-y-1/2 "
                            ++ (if asc then
                                    "fa-sort-up"

                                else
                                    "fa-sort-down"
                               )
                        )
                    , A.attribute "aria-hidden" "true"
                    ]
                    []

              else
                text ""
            ]
        ]


tdL : Html msg -> Html msg
tdL x =
    td [ A.class "h-16 px-6 py-0 border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center text-2xl" ] [ x ] ]


tdC : String -> Html msg
tdC s =
    td [ A.class "h-16 px-6 py-0 text-center border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center justify-center text-2xl" ] [ text s ] ]


tdCBool : Bool -> Html msg
tdCBool b =
    tdC
        (if b then
            "✓"

         else
            "—"
        )


view : Props msg -> Html msg
view props =
    let
        half =
            node "col" [ A.attribute "style" "width:50%" ] []

        sixth =
            node "col" [ A.attribute "style" "width:16.6667%" ] []
    in
    table
        [ A.class "w-full table-fixed border-separate border-spacing-0 m-0"
        , A.attribute "role" "grid"
        , A.attribute "aria-colcount" "4"
        , A.attribute "aria-label" "Problems"
        ]
        [ node "colgroup" [] [ half, sixth, sixth, sixth ]
        , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60 bg-base-100", A.attribute "role" "rowgroup" ]
            [ tr [ A.attribute "role" "row" ]
                [ thc props.sortBy props.asc "TITLE" PByTitle props.onSort
                , thc props.sortBy props.asc "ID" PById props.onSort
                , thc props.sortBy props.asc "DATE" PByDate props.onSort
                , thc props.sortBy props.asc "SOLVED" PBySolved props.onSort
                ]
            ]
        , tbody [ A.attribute "role" "rowgroup" ]
            (List.map
                (\p ->
                    tr [ A.attribute "role" "row" ]
                        [ tdL (a [ A.href ("#problem-" ++ p.id), A.class "link" ] [ text p.title ])
                        , tdC p.id
                        , tdC p.date
                        , tdCBool p.solved
                        ]
                )
                props.problems
            )
        ]
