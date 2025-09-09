module Lib.CourseOps exposing (sort)

import Types exposing (Course, SortBy(..))


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
