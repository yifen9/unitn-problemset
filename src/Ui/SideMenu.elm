module Ui.SideMenu exposing (view)

import Html exposing (Html, a, li, nav, text, ul)
import Html.Attributes as A


view : Html msg
view =
    nav [ A.class "p-2" ]
        [ ul [ A.class "menu w-full" ]
            [ li [] [ a [ A.href "/" ] [ text "Home" ] ]
            ]
        ]
