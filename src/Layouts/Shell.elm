module Layouts.Shell exposing (view)

import Html exposing (Html, aside, div, main_, section)
import Html.Attributes as A
import Ui.Footer as Footer
import Ui.Header as Header
import Ui.SideMenu as SideMenu
import Ui.UserPanel as UserPanel
import Types exposing (User)

view : Maybe User -> Html msg -> Html msg
view user content =
    section []
        [ Header.view user
        , div [ A.class "pt-14 min-h-dvh bg-base-100 text-base-content" ]
            [ div [ A.class "w-full" ]
                [ div [ A.class "grid grid-cols-1 lg:grid-cols-12 divide-x divide-base-300/60" ]
                    [ aside [ A.class "hidden lg:block lg:col-span-2" ]
                        [ div [ A.class "sticky top-14 h-[calc(100dvh-3.5rem)] overflow-y-auto" ] [ SideMenu.view ] ]
                    , main_ [ A.class "lg:col-span-8 p-6 min-h-[60dvh]" ] [ content ]
                    , aside [ A.class "hidden lg:block lg:col-span-2" ]
                        [ div [ A.class "sticky top-14 h-[calc(100dvh-3.5rem)] overflow-y-auto p-4" ] [ UserPanel.view user ] ]
                    ]
                ]
            ]
        , Footer.view
        ]
