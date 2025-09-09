module Main exposing (main)

import Browser
import Html exposing (div, text)


main : Program () () Never
main =
    Browser.sandbox
        { init = ()
        , update = \_ m -> m
        , view = \_ -> div [] [ text "Hello, World!" ]
        }
