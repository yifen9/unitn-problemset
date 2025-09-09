module Ui.SideMenu exposing (view)

import Html exposing (Html, a, div, nav, text)
import Html.Attributes as A

view : Html msg
view =
    nav []
        [ div [ A.class "p-4 space-y-2" ]
            [ a [ A.href "/", A.class "btn btn-ghost justify-start w-full" ] [ text "Home" ]
            , a [ A.href "/subjects", A.class "btn btn-ghost justify-start w-full" ] [ text "Subjects" ]
            , a [ A.href "/history", A.class "btn btn-ghost justify-start w-full" ] [ text "History" ]
            ]
        ]
