module Ui.CourseSidebar exposing (view)

import Html exposing (Html, button, div, text)
import Html.Attributes as A


type alias Props =
    { startEnabled : Bool
    }


view : Props -> Html msg
view props =
    div [ A.class "grid grid-rows-[4rem_1fr] h-full" ]
        [ div [ A.class "grid grid-cols-3 items-center gap-2 p-2" ]
            [ button [ A.class "btn btn-primary w-full" ] [ text "IMPORT" ]
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
            , button [ A.class "btn w-full" ] [ text "EXPORT" ]
            ]
        , div [ A.class "p-4 grid gap-4 content-start" ] []
        ]
