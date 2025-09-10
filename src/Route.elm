module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as P
import Url.Parser.Query as Q


type Route
    = Home
    | Course String
    | Problem String String
    | ProblemResult String String
    | Result String


fromUrl : Url -> Route
fromUrl url =
    let
        qp =
            Q.map4 (\c p s r -> { course = c, problem = p, solution = s, result = r })
                (Q.string "course")
                (Q.string "problem")
                (Q.string "solution")
                (Q.string "result")
    in
    case P.parse (P.query qp) url of
        Just params ->
            case params.course of
                Just cid ->
                    case params.problem of
                        Just pid ->
                            case params.solution of
                                Just _ ->
                                    ProblemResult cid pid

                                Nothing ->
                                    Problem cid pid

                        Nothing ->
                            case params.result of
                                Just _ ->
                                    Result cid

                                Nothing ->
                                    Course cid

                Nothing ->
                    Home

        Nothing ->
            Home
