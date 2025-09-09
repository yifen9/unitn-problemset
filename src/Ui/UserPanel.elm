module Ui.UserPanel exposing (view)

import Html exposing (Html, a, div, p, text)
import Html.Attributes as A
import Types exposing (User)

view : Maybe User -> Html msg
view user =
    case user of
        Just u ->
            div [ A.class "p-4 space-y-2" ]
                [ p [] [ text u.email ]
                , case u.slug of
                    Just s -> a [ A.href ("/users/" ++ s), A.class "link" ] [ text "Profile" ]
                    Nothing -> text ""
                ]

        Nothing ->
            div [ A.class "p-4" ] [ a [ A.href "/login", A.class "btn btn-primary btn-sm" ] [ text "Login" ] ]
