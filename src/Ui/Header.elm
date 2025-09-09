module Ui.Header exposing (view)

import Html exposing (Html, a, div, header, text)
import Html.Attributes as A


view : Html msg
view =
    header [ A.class "navbar fixed top-0 inset-x-0 z-50 h-14 bg-base-100 border-b-2 border-base-300/60" ]
        [ div [ A.class "navbar-start" ]
            [ a [ A.href "/", A.class "btn btn-ghost text-2xl font-bold" ] [ text "UniTN Problemset" ] ]
        , div [ A.class "navbar-end gap-2" ] []
        ]
