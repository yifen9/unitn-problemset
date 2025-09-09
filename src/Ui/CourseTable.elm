module Ui.CourseTable exposing (view)

import Html exposing (Html, a, node, table, tbody, td, th, thead, tr, text)
import Html.Attributes as A
import Html.Events as E
import Types exposing (Course, SortBy(..))

type alias Props msg =
    { courses : List Course
    , sortBy : SortBy
    , asc : Bool
    , onSort : SortBy -> msg
    }

thc : String -> SortBy -> (SortBy -> msg) -> Html msg
thc label key onSort =
    th
        [ A.class "px-6 py-5 text-2xl font-bold uppercase text-center bg-base-200 border-b-2 border-r-2 last:border-r-0 border-base-300/60 cursor-pointer select-none"
        , E.onClick (onSort key)
        ]
        [ text label ]

tdName : Course -> Html msg
tdName c =
    td [ A.class "px-6 py-5 text-2xl border-b-2 border-r-2 last:border-r-0 border-base-300/60" ]
        [ a [ A.href ("/?subject=" ++ c.id), A.class "link" ] [ text c.name ] ]

tdC : String -> Html msg
tdC s =
    td [ A.class "px-6 py-5 text-2xl text-center border-b-2 border-r-2 last:border-r-0 border-base-300/60" ] [ text s ]

view : Props msg -> Html msg
view props =
    let
        half = node "col" [ A.attribute "style" "width:50%" ] []
        sixth = node "col" [ A.attribute "style" "width:16.6667%" ] []
    in
    table [ A.class "w-full table-fixed border-collapse m-0" ]
        [ node "colgroup" [] [ half, sixth, sixth, sixth ]
        , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60" ]
            [ tr []
                [ thc "NAME" ByName props.onSort
                , thc "ID" ById props.onSort
                , thc "SIZE" BySize props.onSort
                , thc "COVERAGE" ByCoverage props.onSort
                ]
            ]
        , tbody []
            (List.map
                (\c ->
                    tr []
                        [ tdName c
                        , tdC c.id
                        , tdC (String.fromInt c.size)
                        , tdC (String.fromInt c.coverage)
                        ]
                )
                props.courses
            )
        ]
