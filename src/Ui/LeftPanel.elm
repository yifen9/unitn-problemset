module Ui.LeftPanel exposing (Props, view, viewActions, viewSettings)

import Html exposing (Html, button, div, text)
import Html.Attributes as A
import Ui.Subheader as Sub


type alias Props =
    { startEnabled : Bool
    }


view : Props -> Html msg
view props =
    div [ A.class "grid grid-rows-[4rem_4rem_1fr] h-full" ]
        [ viewActions props
        , Sub.view "CONFIG"
        , viewSettings
        ]


viewActions : Props -> Html msg
viewActions props =
    div [ A.class "grid grid-cols-3 gap-2 p-2 h-16 items-center justify-items-center border-b-2 border-base-300/60" ]
        [ button [ A.class "btn w-full btn-disabled", A.disabled True ] [ text "IMPORT" ]
        , button
            ([ A.class
                ("btn w-full "
                    ++ (if props.startEnabled then
                            "btn-secondary"

                        else
                            "btn-disabled"
                       )
                )
             ]
                ++ (if props.startEnabled then
                        []

                    else
                        [ A.disabled True ]
                   )
            )
            [ text "START" ]
        , button [ A.class "btn w-full btn-disabled", A.disabled True ] [ text "EXPORT" ]
        ]


viewSettings : Html msg
viewSettings =
    div [ A.class "h-full p-4 grid gap-4 content-start" ] []
