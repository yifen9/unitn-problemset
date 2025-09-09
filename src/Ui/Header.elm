module Ui.Header exposing (view)

import Html exposing (Html, a, button, div, form, header, text)
import Html.Attributes as A
import Types exposing (User)

view : Maybe User -> Html msg
view user =
    header [ A.class "navbar fixed top-0 inset-x-0 z-50 h-14 bg-base-100 border-b border-base-300/60" ]
        [ div [ A.class "navbar-start" ]
            [ a [ A.href "/", A.class "btn btn-ghost text-lg font-semibold" ] [ text "unitn-oj" ] ]
        , div [ A.class "navbar-end gap-2" ]
            [ case user of
                Just _ ->
                    div []
                        [ a [ A.href "/users/me", A.class "btn btn-sm btn-ghost" ] [ text "Profile" ]
                        , form [ A.attribute "method" "POST", A.attribute "action" "/api/v1/auth/logout" ]
                            [ button [ A.type_ "submit", A.class "btn btn-sm" ] [ text "Logout" ] ]
                        ]

                Nothing ->
                    a [ A.href "/login", A.class "btn btn-sm btn-primary" ] [ text "Login" ]
            ]
        ]
