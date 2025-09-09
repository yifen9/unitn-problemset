module Ui.CourseSidebar exposing (view)

import Html exposing (Html, button, div, text)
import Html.Attributes as A


view : Html msg
view =
    div [ A.class "grid grid-rows-[4rem,1fr] h-full" ]
        [ div [ A.class "grid grid-cols-3 gap-3 p-3" ]
            [ button [ A.class "btn btn-primary w-full" ] [ text "IMPORT" ]
            , button [ A.class "btn btn-secondary w-full" ] [ text "START" ]
            , button [ A.class "btn w-full" ] [ text "EXPORT" ]
            ]
        , div [ A.class "p-4 grid gap-4 content-start" ] []
        ]
