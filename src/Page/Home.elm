module Page.Home exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes as A

view : Html msg
view =
    div [ A.class "text-base-content" ] [ text "Hello, World!" ]
