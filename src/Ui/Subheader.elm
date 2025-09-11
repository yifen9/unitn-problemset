module Ui.Subheader exposing (view)

import Html exposing (Html, div, span, text)
import Html.Attributes as A

view : String -> Html msg
view label =
    div [ A.class "h-16 flex items-center justify-center border-b-2 border-base-300/60 text-2xl" ]
        [ span [ A.class "badge badge-outline text-2xl px-4" ] [ text label ] ]