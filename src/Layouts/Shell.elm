module Layouts.Shell exposing (view)

import Html exposing (Html, aside, div, main_, section)
import Html.Attributes as A
import Ui.Footer as Footer
import Ui.Header as Header
import Ui.RightPanel as RightPanel
import Ui.SideMenu as SideMenu


view : Html msg -> Html msg -> Html msg
view content rightPanel =
    section []
        [ Header.view
        , div [ A.class "pt-14 min-h-dvh bg-base-100 text-base-content" ]
            [ div [ A.class "w-full" ]
                [ div [ A.class "grid grid-cols-1 lg:grid-cols-12 divide-x divide-base-300/60" ]
                    [ aside [ A.class "hidden lg:block lg:col-span-2" ]
                        [ div [ A.class "sticky top-14 h-[calc(100dvh-3.5rem)] overflow-y-auto" ] [ SideMenu.view ] ]
                    , main_ [ A.class "lg:col-span-8 p-6 min-h-[60dvh]" ] [ content ]
                    , aside [ A.class "hidden lg:block lg:col-span-2" ]
                        [ div [ A.class "sticky top-14 h-[calc(100dvh-3.5rem)] overflow-y-auto p-4" ]
                            [ ifHtml rightPanel ]
                        ]
                    ]
                ]
            ]
        , Footer.view
        ]


ifHtml : Html msg -> Html msg
ifHtml h =
    case h of
        _ ->
            h
