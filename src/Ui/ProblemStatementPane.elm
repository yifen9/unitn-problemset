module Ui.ProblemStatementPane exposing (view)

import Html exposing (Html, div)
import Html.Attributes as A
import Types exposing (ProblemDetail)
import Ui.ProblemContent as PC


view : ProblemDetail -> Html msg
view d =
    div [ A.class "h-full" ] [ PC.view d ]
