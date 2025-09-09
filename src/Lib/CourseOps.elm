module Lib.CourseOps exposing (sort)

import Types exposing (Course, SortBy(..))


sort : SortBy -> Bool -> List Course -> List Course
sort key asc xs =
    let
        cmp a b =
            case key of
                CByTitle ->
                    compare a.title b.title

                CById ->
                    compare a.id b.id

                CByDate ->
                    compare a.date b.date

                CByCount ->
                    compare a.count b.count

        s =
            List.sortWith cmp xs
    in
    if asc then
        s

    else
        List.reverse s
