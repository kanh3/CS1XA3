import Browser
import Html exposing (Html, Attribute, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

main =
 Browser.sandbox { init = init, update = update, view = view }

-- Model
type alias Model = {content1 : String
                   ,content2 : String}

type Msg = Change1 String | Change2 String

init : Model
init = {content1 = "", content2 =""}

-- View
view : Model -> Html Msg
view model = div []
             [input[ placeholder "String 1", value model.content1, onInput Change1 ] []
             ,input[ placeholder "String 2", value model.content2, onInput Change2 ] []
             ,div [] [ text (model.content1 ++":"++ model.content2) ]
             ]

-- Update
update : Msg -> Model -> Model
update msg model =
      case msg of
        Change1 newContent -> { model | content1 = newContent}
        Change2 newContent -> { model | content2 = newContent}
