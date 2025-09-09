module Layouts.Shell exposing (view)

import Html exposing (Html, aside, div, main_, section)
import Html.Attributes as A
import Ui.Header as Header
import Ui.RightPanel as RightPanel
import Ui.SideMenu as SideMenu


view : Html msg -> Html msg -> Html msg
view content rightPanel =
    section []
        [ Header.view
        , div [ A.class "pt-14 bg-base-100 text-base-content" ]
            [ div [ A.class "h-[calc(100dvh-3.5rem)] overflow-hidden" ]
                [ div [ A.class "grid grid-cols-1 lg:grid-cols-12 divide-x-2 divide-base-300/60 h-full" ]
                    [ aside [ A.class "hidden lg:block lg:col-span-2 h-full overflow-hidden" ] [ SideMenu.view ]
                    , main_ [ A.class "lg:col-span-8 h-full overflow-hidden p-0 m-0" ] [ content ]
                    , aside [ A.class "hidden lg:block lg:col-span-2 h-full overflow-hidden p-4" ] [ rightPanel ]
                    ]
                ]
            ]
        ]
