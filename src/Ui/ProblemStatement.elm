module Ui.ProblemStatement exposing (view)

import Html exposing (Html, span, text)
import Html.Attributes as A
import Types exposing (ProblemDetail, ProblemType(..))
import Ui.ColumnSection as Section
import Ui.ContentBlock as Block
import Ui.Math as Math


view : ProblemDetail -> Html msg
view d =
    let
        tlabel =
            case d.ptype of
                Single ->
                    "SINGLE"

                Multi ->
                    "MULTI"
    in
    Section.view
        { topLeft = text "DATE"
        , topRight = text "TYPE"
        , bottomLeft = span [ A.class "badge badge-outline" ] [ text d.date ]
        , bottomRight = span [ A.class "badge badge-outline" ] [ text tlabel ]
        , body =
            Block.view
                { title = text d.title
                , content = Math.block d.questionMd
                }
        }
