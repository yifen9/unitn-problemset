module Ui.CourseTable exposing (view)

import Html exposing (Html, a, i, node, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events as E
import Types exposing (Course, SortBy(..))


type alias Props msg =
    { courses : List Course
    , sortBy : SortBy
    , asc : Bool
    , onSort : SortBy -> msg
    }


ariaSort : SortBy -> Bool -> SortBy -> String
ariaSort current asc key =
    if key /= current then
        "none"

    else if asc then
        "ascending"

    else
        "descending"


thc : SortBy -> Bool -> String -> SortBy -> (SortBy -> msg) -> Html msg
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


tdName : Course -> Html msg
tdName c =
    td [ A.class "h-16 px-6 py-0 border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center" ]
            [ a [ A.href ("/?course=" ++ c.id), A.class "link text-2xl" ] [ text c.title ] ]
        ]


tdC : String -> Html msg
tdC s =
    td [ A.class "h-16 px-6 py-0 text-center border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ span [ A.class "h-full flex items-center justify-center text-2xl" ] [ text s ] ]


view : Props msg -> Html msg
view props =
    let
        half =
            node "col" [ A.attribute "style" "width:50%" ] []

        sixth =
            node "col" [ A.attribute "style" "width:16.6667%" ] []

        rowCount =
            List.length props.courses + 1
    in
    table
        [ A.class "w-full table-fixed border-separate border-spacing-0 m-0"
        , A.attribute "role" "grid"
        , A.attribute "aria-colcount" "4"
        , A.attribute "aria-rowcount" (String.fromInt rowCount)
        , A.attribute "aria-label" "Courses"
        ]
        [ node "colgroup" [] [ half, sixth, sixth, sixth ]
        , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60 bg-base-100", A.attribute "role" "rowgroup" ]
            [ tr [ A.attribute "role" "row" ]
                [ thc props.sortBy props.asc "TITLE" CByTitle props.onSort
                , thc props.sortBy props.asc "ID" CById props.onSort
                , thc props.sortBy props.asc "DATE" CByDate props.onSort
                , thc props.sortBy props.asc "COUNT" CByCount props.onSort
                ]
            ]
        , tbody [ A.attribute "role" "rowgroup" ]
            (List.map
                (\c ->
                    tr [ A.attribute "role" "row" ]
                        [ tdName c
                        , tdC c.id
                        , tdC c.date
                        , tdC (String.fromInt c.count)
                        ]
                )
                props.courses
            )
        ]
