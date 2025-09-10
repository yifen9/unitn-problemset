module Lib.ProblemOps exposing (eqSet, sortProblems)

import Types exposing (Problem, ProblemSortBy(..))


eqSet : List String -> List String -> Bool
eqSet a b =
    List.sort a == List.sort b


sortProblems : ProblemSortBy -> Bool -> List Problem -> List Problem
sortProblems key asc xs =
    let
        cmp a b =
            case key of
                PByTitle ->
                    compare a.title b.title

                PById ->
                    compare a.id b.id

                PByDate ->
                    compare a.date b.date

                PBySolved ->
                    let
                        ai =
                            if a.solved then
                                1

                            else
                                0

                        bi =
                            if b.solved then
                                1

                            else
                                0
                    in
                    case compare ai bi of
                        EQ ->
                            compare a.title b.title

                        ord ->
                            ord

        s =
            List.sortWith cmp xs
    in
    if asc then
        s

    else
        List.reverse s
