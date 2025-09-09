module Ui.Header exposing (view)

import Html exposing (Html, a, div, header, i, text)
import Html.Attributes as A


view : Html msg
view =
    header [ A.class "navbar fixed top-0 inset-x-0 z-50 h-14 bg-base-100 border-b-2 border-base-300/60" ]
        [ div [ A.class "navbar-start" ]
            [ a [ A.href "/", A.class "btn btn-ghost text-2xl font-bold" ] [ text "UniTN Problemset" ] ]
        , div [ A.class "navbar-end gap-1 pr-2" ]
            [ iconLink "https://webapps.unitn.it/gestionecorsi" "Moodle" "fa-solid fa-graduation-cap"
            , iconLink "https://discord.com/invite/your-server" "Discord" "fa-brands fa-discord"
            , iconLink "https://github.com/yifen9/unitn-problemset" "GitHub" "fa-brands fa-github"
            ]
        ]


iconLink : String -> String -> String -> Html msg
iconLink url label iconClass =
    a
        [ A.href url
        , A.target "_blank"
        , A.rel "noreferrer"
        , A.attribute "aria-label" label
        , A.class "btn btn-ghost btn-square"
        ]
        [ i [ A.class ("text-2xl " ++ iconClass) ] [] ]
