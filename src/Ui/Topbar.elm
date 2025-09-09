module Ui.Topbar exposing (viewTitle, viewSearch, viewIcons)

import Html exposing (Html, a, div, i, input, text)
import Html.Attributes as A
import Html.Events as E

viewTitle : Html msg
viewTitle =
    a [ A.href "/", A.class "btn btn-ghost text-2xl font-bold" ] [ text "UniTN Problemset" ]

viewSearch : (String -> msg) -> String -> Html msg
viewSearch onQuery q =
    input
        [ A.class "input input-bordered w-full max-w-[min(80ch,100%)] rounded-md text-xl text-center uppercase font-bold tracking-wide"
        , E.onInput onQuery
        , A.value q
        , A.attribute "aria-label" "Search courses by name or id"
        ]
        []

viewIcons : Html msg
viewIcons =
    div [ A.class "flex items-center gap-2" ]
        [ iconLink "https://moodle.unitn.it/" "Moodle" "fa-solid fa-graduation-cap"
        , iconLink "https://discord.com/invite/your-server" "Discord" "fa-brands fa-discord"
        , iconLink "https://github.com/yifen9/pset" "GitHub" "fa-brands fa-github"
        ]

iconLink : String -> String -> String -> Html msg
iconLink url label iconClass =
    a
        [ A.href url, A.target "_blank", A.rel "noreferrer", A.attribute "aria-label" label
        , A.class "btn btn-ghost btn-square"
        ]
        [ i [ A.class ("text-2xl " ++ iconClass) ] [] ]
