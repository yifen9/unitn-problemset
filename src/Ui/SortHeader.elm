module Ui.SortHeader exposing (ariaSort, view)

import Html exposing (Html, i, span, text, th)
import Html.Attributes as A
import Html.Events as E


ariaSort : a -> Bool -> a -> String
ariaSort current asc key =
    if key /= current then
        "none"

    else if asc then
        "ascending"

    else
        "descending"


type alias Props key msg =
    { current : key
    , asc : Bool
    , key : key
    , label : String
    , onSort : key -> msg
    }


view : Props key msg -> Html msg
view p =
    th
        [ A.class "h-16 p-0 bg-base-200 border-b-2 border-base-300/60 border-r-2 last:border-r-0"
        , A.attribute "role" "columnheader"
        , A.attribute "scope" "col"
        , A.attribute "aria-sort" (ariaSort p.current p.asc p.key)
        , E.onClick (p.onSort p.key)
        ]
        [ span [ A.class "relative flex w-full h-full" ]
            [ span [ A.class "absolute inset-0 flex items-center justify-center text-2xl font-bold uppercase" ] [ text p.label ]
            , if p.key == p.current then
                i
                    [ A.class
                        ("fa-solid absolute right-4 top-1/2 -translate-y-1/2 "
                            ++ (if p.asc then
                                    "fa-sort-up"

                                else
                                    "fa-sort-down"
                               )
                        )
                    , A.attribute "aria-hidden" "true"
                    ]
                    []

              else
                text ""
            ]
        ]
