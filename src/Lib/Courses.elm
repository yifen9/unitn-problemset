module Lib.Courses exposing (CourseIndex, decoderIndex, load)

import Http
import Json.Decode as D
import Types exposing (Course)

type alias CourseIndex =
    { build : String
    , courses : List Course
    }

decoderCourse : D.Decoder Course
decoderCourse =
    D.map4 Course
        (D.field "id" D.string)
        (D.field "name" D.string)
        (D.field "size" D.int)
        (D.succeed 0)

decoderIndex : D.Decoder CourseIndex
decoderIndex =
    D.map2 CourseIndex
        (D.field "build" D.string)
        (D.field "courses" (D.list decoderCourse))

load : (Result Http.Error CourseIndex -> msg) -> Cmd msg
load tagger =
    Http.get
        { url = "/data/courses/index.json"
        , expect = Http.expectJson tagger decoderIndex
        }
