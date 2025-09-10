module Ui.ProblemTable exposing (view)

import Html exposing (Html, a, node, table, tbody, text, thead, tr)
import Html.Attributes as A
import Types exposing (Problem, ProblemSortBy(..))
import Ui.SortHeader as SH
import Ui.Table as T


type alias Props msg =
    { courseId : String
    , problems : List Problem
    , sortBy : ProblemSortBy
    , asc : Bool
    , onSort : ProblemSortBy -> msg
    }


tdBool : Bool -> Html msg
tdBool b =
    T.tdCenterText
        (if b then
            "✓"

         else
            "—"
        )


view : Props msg -> Html msg
view props =
    table
        (T.baseTableAttrs { label = "Problems", cols = 4, rows = Nothing })
        [ node "colgroup" [] [ T.col 50, T.col 16.6667, T.col 16.6667, T.col 16.6667 ]
        , thead [ A.class "sticky top-0 z-10 border-b-2 border-base-300/60 bg-base-100", A.attribute "role" "rowgroup" ]
            [ tr [ A.attribute "role" "row" ]
                [ SH.view { current = props.sortBy, asc = props.asc, key = PByTitle, label = "TITLE", onSort = props.onSort }
                , SH.view { current = props.sortBy, asc = props.asc, key = PById, label = "ID", onSort = props.onSort }
                , SH.view { current = props.sortBy, asc = props.asc, key = PByDate, label = "DATE", onSort = props.onSort }
                , SH.view { current = props.sortBy, asc = props.asc, key = PBySolved, label = "SOLVED", onSort = props.onSort }
                ]
            ]
        , tbody [ A.attribute "role" "rowgroup" ]
            (List.map
                (\p ->
                    tr [ A.attribute "role" "row" ]
                        [ T.td [ a [ A.href ("/?course=" ++ props.courseId ++ "&problem=" ++ p.id), A.class "link" ] [ text p.title ] ]
                        , T.tdCenterText p.id
                        , T.tdCenterText p.date
                        , tdBool p.solved
                        ]
                )
                props.problems
            )
        ]
