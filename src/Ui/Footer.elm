module Ui.Footer exposing (view)

import Html exposing (Html, div, footer, text)
import Html.Attributes as A

view : Html msg
view =
    footer [ A.class "border-t border-base-300/60 bg-base-100" ]
        [ div [ A.class "px-4 py-6 text-sm opacity-70" ] [ text "footer placeholder" ] ]
