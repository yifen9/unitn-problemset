module Layouts.Shell exposing (view)

import Html exposing (Html, aside, div, main_, section)
import Html.Attributes as A
import Ui.Topbar as Topbar


view : Html msg -> Html msg -> Html msg -> Html msg -> Html msg
view topCenter leftPanel content rightPanel =
    section
        [ A.class "grid grid-rows-[4rem_1fr] grid-cols-[1fr_3fr_1fr] h-[100dvh] bg-base-100 text-base-content"
        , A.attribute "role" "application"
        ]
        [ div [ A.class "row-start-1 col-start-1 flex items-center justify-center border-b-2 border-base-300/60" ] [ Topbar.viewTitle ]
        , div [ A.class "row-start-1 col-start-2 flex items-center justify-center border-b-2 border-base-300/60" ] [ topCenter ]
        , div [ A.class "row-start-1 col-start-3 flex items-center justify-center border-b-2 border-base-300/60" ] [ Topbar.viewIcons ]
        , aside [ A.class "row-start-2 col-start-1 overflow-y-auto border-r-2 border-base-300/60" ] [ leftPanel ]
        , main_ [ A.class "row-start-2 col-start-2 overflow-y-auto border-r-2 border-base-300/60 p-0 m-0" ] [ content ]
        , aside [ A.class "row-start-2 col-start-3 overflow-y-auto border-r-2 border-base-300/60" ] [ rightPanel ]
        ]
