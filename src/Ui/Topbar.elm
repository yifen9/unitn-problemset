module Ui.Topbar exposing (viewIcons, viewTitle)

import Html exposing (Html, a, div, i, text)
import Html.Attributes as A


viewTitle : Html msg
viewTitle =
    a [ A.href "/", A.class "btn btn-ghost text-2xl font-bold" ] [ text "UniTN Problemset" ]


viewIcons : Html msg
viewIcons =
    div [ A.class "flex items-center gap-2" ]
        [ iconLink "https://webapps.unitn.it/gestionecorsi" "Moodle" "fa-solid fa-graduation-cap"
        , iconLink "https://discord.gg/f3tNxeHTYU" "Discord" "fa-brands fa-discord"
        , iconLink "https://github.com/yifen9/unitn-problemset" "GitHub" "fa-brands fa-github"
        ]


iconLink : String -> String -> String -> Html msg
iconLink url label iconClass =
    a [ A.href url, A.target "_blank", A.rel "noreferrer", A.attribute "aria-label" label, A.class "btn btn-ghost btn-square" ]
        [ i [ A.class ("text-2xl " ++ iconClass) ] [] ]
