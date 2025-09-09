module Layouts.Shell exposing (view)

import Html exposing (Html, aside, div, main_, section)
import Html.Attributes as A
import Ui.Topbar as Topbar
import Ui.SideMenu as SideMenu

view : (String -> msg) -> String -> Html msg -> Html msg -> Html msg
view onQuery q content rightPanel =
    section
        [ A.class "grid grid-rows-[3.5rem,1fr] grid-cols-[2fr_8fr_2fr] h-[100dvh] bg-base-100 text-base-content divide-x-2 divide-base-300/60"
        , A.attribute "role" "application"
        ]
        [ div [ A.class "row-start-1 col-start-1 flex items-center justify-center border-b-2 border-base-300/60" ] [ Topbar.viewTitle ]
        , div [ A.class "row-start-1 col-start-2 flex items-center justify-center border-b-2 border-base-300/60" ] [ Topbar.viewSearch onQuery q ]
        , div [ A.class "row-start-1 col-start-3 flex items-center justify-center border-b-2 border-base-300/60" ] [ Topbar.viewIcons ]
        , aside [ A.class "row-start-2 col-start-1 overflow-y-auto" ] [ SideMenu.view ]
        , main_ [ A.class "row-start-2 col-start-2 overflow-y-auto p-0 m-0" ] [ content ]
        , aside [ A.class "row-start-2 col-start-3 overflow-y-auto p-4" ] [ rightPanel ]
        ]
