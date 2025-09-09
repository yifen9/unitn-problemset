module Lib.Courses exposing (CourseIndex, LoadResult, decoderIndex, load)

import Http
import Json.Decode as D
import Types exposing (Course)


type alias CourseIndex =
    { build : String
    , courses : List Course
    }


type alias LoadResult =
    Result Http.Error CourseIndex


decoderCourse : D.Decoder Course
decoderCourse =
    D.map4 Course
        (D.field "id" D.string)
        (D.field "title" D.string)
        (D.field "date" D.string)
        (D.field "count" D.int)


decoderIndex : D.Decoder CourseIndex
decoderIndex =
    D.map2 CourseIndex
        (D.field "build" D.string)
        (D.field "courses" (D.list decoderCourse))


load : (LoadResult -> msg) -> Cmd msg
load tagger =
    Http.get
        { url = "/data/courses/index.json"
        , expect = Http.expectJson tagger decoderIndex
        }
