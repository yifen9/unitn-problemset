module Lib.Problems exposing (Index, LoadIndexResult, LoadOneResult, decoderIndex, decoderProblem, loadIndex, loadOne)

import Http
import Json.Decode as D
import Types exposing (Choice, ProblemDetail, ProblemSummary, ProblemType(..))


type alias Index =
    { courseId : String
    , build : String
    , count : Int
    , problems : List ProblemSummary
    }


type alias LoadIndexResult =
    Result Http.Error Index


type alias LoadOneResult =
    Result Http.Error ProblemDetail


decoderSummary : D.Decoder ProblemSummary
decoderSummary =
    D.map4 ProblemSummary
        (D.field "id" D.string)
        (D.field "title" D.string)
        (D.field "date" D.string)
        (D.field "path" D.string)


decoderIndex : D.Decoder Index
decoderIndex =
    D.map4 Index
        (D.field "courseId" D.string)
        (D.field "build" D.string)
        (D.field "count" D.int)
        (D.field "problems" (D.list decoderSummary))


decoderProblemType : D.Decoder ProblemType
decoderProblemType =
    D.oneOf
        [ D.field "type" D.string
            |> D.andThen
                (\s ->
                    case String.toLower s of
                        "single" ->
                            D.succeed Single

                        "multi" ->
                            D.succeed Multi

                        _ ->
                            D.succeed Single
                )
        , D.succeed Single
        ]


decoderChoice : D.Decoder Choice
decoderChoice =
    D.map2 Choice
        (D.field "id" D.string)
        (D.field "text_md" D.string)


decoderProblem : D.Decoder ProblemDetail
decoderProblem =
    D.map8 ProblemDetail
        (D.field "id" D.string)
        (D.field "title" D.string)
        (D.field "date" D.string)
        (D.oneOf [ decoderProblemType, D.succeed Single ])
        (D.field "question_md" D.string)
        (D.field "choices" (D.list decoderChoice))
        (D.field "answer" (D.list D.string))
        (D.oneOf [ D.field "explanation_md" D.string, D.succeed "" ])


loadIndex : String -> (LoadIndexResult -> msg) -> Cmd msg
loadIndex courseId tagger =
    Http.get
        { url = "/data/courses/" ++ courseId ++ "/problems/index.json"
        , expect = Http.expectJson tagger decoderIndex
        }


loadOne : String -> String -> (LoadOneResult -> msg) -> Cmd msg
loadOne courseId path tagger =
    Http.get
        { url = "/data/courses/" ++ courseId ++ "/problems/" ++ path
        , expect = Http.expectJson tagger decoderProblem
        }
