module Ui.CourseTable exposing (view)

import Html exposing (Html, a, node, table, tbody, text, thead, tr)
import Html.Attributes as A
import Html.Events as E
import Types exposing (Course, SortBy(..))
import Ui.SortHeader as SH
import Ui.Table as T


type alias Props msg =
    { courses : List Course
    , sortBy : SortBy
    , asc : Bool
    , onSort : SortBy -> msg
    }


view : Props msg -> Html msg
view props =
    let
        rowCount =
            List.length props.courses + 1
    in
    table
        (T.baseTableAttrs { label = "Courses", cols = 4, rows = Just rowCount })
        [ node "colgroup" [] [ T.col 50, T.col 16.6667, T.col 16.6667, T.col 16.6667 ]
        , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60 bg-base-100", A.attribute "role" "rowgroup" ]
            [ tr [ A.attribute "role" "row" ]
                [ SH.view { current = props.sortBy, asc = props.asc, key = CByTitle, label = "TITLE", onSort = props.onSort }
                , SH.view { current = props.sortBy, asc = props.asc, key = CById, label = "ID", onSort = props.onSort }
                , SH.view { current = props.sortBy, asc = props.asc, key = CByDate, label = "DATE", onSort = props.onSort }
                , SH.view { current = props.sortBy, asc = props.asc, key = CByCount, label = "COUNT", onSort = props.onSort }
                ]
            ]
        , tbody [ A.attribute "role" "rowgroup" ]
            (List.map
                (\c ->
                    tr [ A.attribute "role" "row" ]
                        [ T.td [ a [ A.href ("/?course=" ++ c.id), A.class "link text-2xl" ] [ text c.title ] ]
                        , T.tdCenterText c.id
                        , T.tdCenterText c.date
                        , T.tdCenterText (String.fromInt c.count)
                        ]
                )
                props.courses
            )
        ]
