module Ui.ProblemSolution exposing (view)

import Html exposing (Html, span, text)
import Html.Attributes as A
import Types exposing (ProblemDetail)
import Ui.ColumnSection as Section
import Ui.ContentBlock as Block
import Ui.Math as Math

type alias Props =
    { detail : ProblemDetail
    , selected : List String
    }

eqSet : List String -> List String -> Bool
eqSet a b =
    List.sort a == List.sort b

view : Props -> Html msg
view props =
    let
        d = props.detail
        chosen =
            if List.isEmpty props.selected then
                "—"
            else
                String.join ", " props.selected

        answerId =
            if List.isEmpty d.answer then
                "—"
            else
                String.join ", " d.answer
    in
    Section.view
        { topLeft = text "RESULT"
        , topRight = text "ANSWER"
        , bottomLeft = span [ A.class "badge badge-outline" ] [ text chosen ]
        , bottomRight = span [ A.class "badge badge-outline" ] [ text answerId ]
        , body =
            Block.view
                { title = text "SOLUTION"
                , content = Math.block d.explanationMd
                }
        }