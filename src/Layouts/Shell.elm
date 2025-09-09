module Layouts.Shell exposing (view)

import Html exposing (Html, aside, div, main_, section)
import Html.Attributes as A
import Ui.Header as Header
import Ui.RightPanel as RightPanel
import Ui.SideMenu as SideMenu


view : (String -> msg) -> String -> Html msg -> Html msg -> Html msg
view onQuery q content rightPanel =
    section []
        [ Header.viewWithSearch onQuery q
        , div [ A.class "pt-14 bg-base-100 text-base-content" ]
            [ div [ A.class "relative h-[calc(100dvh-3.5rem)] overflow-hidden" ]
                [ div
                    [ A.class "grid grid-cols-12 grid-rows-[auto,1fr] h-full divide-x-2 divide-base-300/60" ]
                    [ aside [ A.class "hidden lg:block col-span-2 row-span-2 overflow-auto" ] [ SideMenu.view ]
                    , main_ [ A.class "col-span-8 row-span-2 overflow-hidden p-0 m-0" ] [ content ]
                    , aside [ A.class "hidden lg:block col-span-2 row-span-2 overflow-auto p-4" ] [ rightPanel ]
                    ]
                ]
            ]
        ]
