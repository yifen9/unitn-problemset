module Ui.CourseTable exposing (view)

import Html exposing (Html, a, div, i, node, table, tbody, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events as E
import Types exposing (Course, SortBy(..))


type alias Props msg =
    { courses : List Course
    , sortBy : SortBy
    , asc : Bool
    , onSort : SortBy -> msg
    }


thc : SortBy -> Bool -> String -> SortBy -> (SortBy -> msg) -> Html msg
thc current asc label key onSort =
    let
        selected =
            key == current

        baseCls =
            "px-6 py-5 text-2xl font-bold uppercase text-center border-b-2 border-base-300/60 cursor-pointer select-none "

        hl =
            if selected then
                "bg-primary text-primary-content"

            else
                "bg-base-200"
    in
    th
        [ A.class (baseCls ++ hl)
        , E.onClick (onSort key)
        ]
        [ text label
        , if selected then
            i
                [ A.class
                    ("ml-3 fa-solid "
                        ++ (if asc then
                                "fa-sort-up"

                            else
                                "fa-sort-down"
                           )
                    )
                ]
                []

          else
            text ""
        ]


tdName : Course -> Html msg
tdName c =
    td [ A.class "px-6 py-5 text-2xl border-b-2 border-base-300/60" ]
        [ a [ A.href ("/?subject=" ++ c.id), A.class "link" ] [ text c.name ] ]


tdC : String -> Html msg
tdC s =
    td [ A.class "px-6 py-5 text-2xl text-center border-b-2 border-base-300/60" ] [ text s ]


view : Props msg -> Html msg
view props =
    let
        half =
            node "col" [ A.attribute "style" "width:50%" ] []

        sixth =
            node "col" [ A.attribute "style" "width:16.6667%" ] []
    in
    div [ A.class "relative h-full overflow-y-auto" ]
        [ div [ A.class "pointer-events-none absolute inset-y-0 left-1/2 border-l-2 border-base-300/60" ] []
        , div [ A.class "pointer-events-none absolute inset-y-0 left-[66.6667%] border-l-2 border-base-300/60" ] []
        , div [ A.class "pointer-events-none absolute inset-y-0 left-[83.3333%] border-l-2 border-base-300/60" ] []
        , table [ A.class "w-full table-fixed border-collapse m-0" ]
            [ node "colgroup" [] [ half, sixth, sixth, sixth ]
            , thead [ A.class "sticky top-0 z-10" ]
                [ tr []
                    [ thc props.sortBy props.asc "NAME" ByName props.onSort
                    , thc props.sortBy props.asc "ID" ById props.onSort
                    , thc props.sortBy props.asc "SIZE" BySize props.onSort
                    , thc props.sortBy props.asc "COVERAGE" ByCoverage props.onSort
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
        ]
