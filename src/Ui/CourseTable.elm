module Ui.CourseTable exposing (view)

import Html exposing (Html, a, div, i, node, span, table, tbody, td, th, thead, tr, text)
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D
import Types exposing (Course, SortBy(..))

type alias Props msg =
    { courses : List Course
    , sortBy : SortBy
    , asc : Bool
    , onSort : SortBy -> msg
    , onRowKey : Int -> String -> msg
    }

onKeySort : (SortBy -> msg) -> SortBy -> Html.Attribute msg
onKeySort onSort key =
    E.on "keydown" (D.field "key" D.string |> D.andThen (\k -> if k == "Enter" || k == " " then D.succeed (onSort key) else D.fail "skip"))

ariaSort : SortBy -> Bool -> SortBy -> String
ariaSort current asc key =
    if key /= current then "none" else if asc then "ascending" else "descending"

thc : SortBy -> Bool -> String -> SortBy -> (SortBy -> msg) -> Html msg
thc current asc label key onSort =
    th
        [ A.class "h-16 p-0 bg-base-200 border-b-2 border-base-300/60 border-r-2 last:border-r-0"
        , A.attribute "role" "columnheader"
        , A.attribute "scope" "col"
        , A.attribute "tabindex" "0"
        , A.attribute "aria-sort" (ariaSort current asc key)
        , A.attribute "aria-label" (label ++ " column, sortable")
        , E.onClick (onSort key)
        , onKeySort onSort key
        ]
        [ div [ A.class "relative h-full flex items-center justify-center text-2xl font-bold uppercase" ]
            [ span [ A.class "pointer-events-none" ] [ text label ]
            , if key == current then
                i [ A.class ("fa-solid absolute right-4 top-1/2 -translate-y-1/2 " ++ (if asc then "fa-sort-up" else "fa-sort-down")), A.attribute "aria-hidden" "true" ] []
              else
                text ""
            ]
        ]

tdName : Course -> Html msg
tdName c =
    td [ A.class "h-16 px-6 py-0 border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ div [ A.class "h-full flex items-center" ]
            [ a [ A.href ("/?subject=" ++ c.id), A.class "link text-2xl" ] [ text c.name ] ]
        ]

tdC : String -> Html msg
tdC s =
    td [ A.class "h-16 px-6 py-0 text-center border-b-2 border-base-300/60 border-r-2 last:border-r-0" ]
        [ div [ A.class "h-full flex items-center justify-center text-2xl" ] [ text s ] ]

rowKeyAttr : (String -> msg) -> String -> Html.Attribute msg
rowKeyAttr tag rowId =
    E.on "keydown"
        (D.field "key" D.string
            |> D.map (\k -> tag (rowId ++ "|" ++ k))
        )

view : Props msg -> Html msg
view props =
    let
        half = node "col" [ A.attribute "style" "width:50%" ] []
        sixth = node "col" [ A.attribute "style" "width:16.6667%" ] []
        rowCount = List.length props.courses + 1
    in
    div [ A.class "h-full" ]
        [ div [ A.class "sr-only", A.attribute "aria-live" "polite" ]
            [ text
                (case props.sortBy of
                    ByName -> if props.asc then "Sorted by NAME ascending" else "Sorted by NAME descending"
                    ById -> if props.asc then "Sorted by ID ascending" else "Sorted by ID descending"
                    BySize -> if props.asc then "Sorted by SIZE ascending" else "Sorted by SIZE descending"
                    ByCoverage -> if props.asc then "Sorted by COVERAGE ascending" else "Sorted by COVERAGE descending"
                )
            ]
        , table
            [ A.class "w-full table-fixed border-separate border-spacing-0 m-0"
            , A.attribute "role" "grid"
            , A.attribute "aria-colcount" "4"
            , A.attribute "aria-rowcount" (String.fromInt rowCount)
            , A.attribute "aria-label" "Courses"
            ]
            [ node "colgroup" [] [ half, sixth, sixth, sixth ]
            , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60 bg-base-100", A.attribute "role" "rowgroup" ]
                [ tr [ A.attribute "role" "row" ]
                    [ thc props.sortBy props.asc "NAME" ByName props.onSort
                    , thc props.sortBy props.asc "ID" ById props.onSort
                    , thc props.sortBy props.asc "SIZE" BySize props.onSort
                    , thc props.sortBy props.asc "COVERAGE" ByCoverage props.onSort
                    ]
                ]
            , tbody [ A.attribute "role" "rowgroup" ]
                (List.indexedMap
                    (\i c ->
                        let rowId = "row-" ++ String.fromInt i in
                        tr
                            [ A.id rowId
                            , A.attribute "role" "row"
                            , A.attribute "aria-rowindex" (String.fromInt (i + 2))
                            , A.attribute "tabindex" "0"
                            , rowKeyAttr (\payload -> props.onRowKey i payload) rowId
                            ]
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
