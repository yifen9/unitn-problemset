module Lib.CourseOps exposing (filter, sort)

import String
import Types exposing (Course, SortBy(..))


filter : String -> List Course -> List Course
filter q xs =
    let
        t =
            String.toLower q

        f c =
            String.contains t (String.toLower c.name)
                || String.contains t (String.toLower c.id)
    in
    if String.length t == 0 then
        xs

    else
        List.filter f xs


sort : SortBy -> Bool -> List Course -> List Course
sort key asc xs =
    let
        cmp a b =
            case key of
                ByName ->
                    compare a.name b.name

                ById ->
                    compare a.id b.id

                BySize ->
                    compare a.size b.size

                ByCoverage ->
                    compare a.coverage b.coverage

        s =
            List.sortWith cmp xs
    in
    if asc then
        s

    else
        List.reverse s
