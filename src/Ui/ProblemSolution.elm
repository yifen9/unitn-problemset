module Ui.ProblemSolution exposing (view)

import Html exposing (Html, div, h2, p, text)
import Html.Attributes as A
import Types exposing (ProblemDetail)
import Ui.Math as Math


type alias Props =
    { detail : ProblemDetail
    , selected : List String
    }


eqSet : List String -> List String -> Bool
eqSet a b =
    List.sort a == List.sort b


view : Props -> Html msg
view props =
    let
        d =
            props.detail

        correct =
            eqSet props.selected d.answer

        verdictClass =
            if correct then
                "alert alert-success"

            else
                "alert alert-error"

        yourAns =
            if List.isEmpty props.selected then
                "—"

            else
                String.join ", " props.selected

        rightAns =
            if List.isEmpty d.answer then
                "—"

            else
                String.join ", " d.answer

        hasExp =
            String.trim d.explanationMd /= ""
    in
    div [ A.class "h-full p-6 grid gap-4 content-start" ]
        [ div [ A.class verdictClass ]
            [ h2 [ A.class "font-bold text-xl" ]
                [ text
                    (if correct then
                        "Correct"

                     else
                        "Incorrect"
                    )
                ]
            , p [] [ text ("Your answer: " ++ yourAns) ]
            , p [] [ text ("Correct answer: " ++ rightAns) ]
            ]
        , if hasExp then
            div [ A.class "grid gap-2" ]
                [ h2 [ A.class "text-xl font-semibold uppercase tracking-wide" ] [ text "Explanation" ]
                , Math.block d.explanationMd
                ]

          else
            text ""
        ]
