module Types exposing (Choice, Course, Problem, ProblemDetail, ProblemSortBy(..), ProblemSummary, ProblemType(..), SortBy(..))


type alias Course =
    { id : String
    , title : String
    , date : String
    , count : Int
    }


type SortBy
    = CByTitle
    | CById
    | CByDate
    | CByCount


type alias Problem =
    { id : String
    , title : String
    , date : String
    , solved : Bool
    }


type ProblemSortBy
    = PByTitle
    | PById
    | PByDate
    | PBySolved


type ProblemType
    = Single
    | Multi


type alias Choice =
    { id : String
    , textMd : String
    }


type alias ProblemDetail =
    { id : String
    , title : String
    , date : String
    , ptype : ProblemType
    , questionMd : String
    , choices : List Choice
    , answer : List String
    , explanationMd : String
    }


type alias ProblemSummary =
    { id : String
    , title : String
    , date : String
    , path : String
    }
