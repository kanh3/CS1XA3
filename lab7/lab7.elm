module Main exposing (..)
import Browser
import Html exposing(..)
import Http
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import String

-- MAIN
main =
  Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
-- MODEL
type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  , response : String
  }

type Msg
  = Name String
  | Password String
  | PasswordAgain String
  | GotText (Result Http.Error String)
  | ClickSubmit

testPost : Model -> Cmd Msg
testPost model=
  let body1 = "name="++model.name++"&password="++model.password
  in
  Http.post { url = "https://mac1xa3.ca/e/kanh3/lab7/"
            , body=Http.stringBody "application/x-www-form-urlencoded" body1
            , expect= Http.expectString GotText}

init : () -> (Model, Cmd Msg)
init _ =
  ({ name = "",password="",passwordAgain="",response="Waiting for response"} , Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Name name ->
      ({ model | name = name }, Cmd.none)

    Password password ->
      ({ model | password = password }, Cmd.none)

    PasswordAgain password ->
      ({ model | passwordAgain = password }, Cmd.none)

    GotText result ->
            case result of
                Ok val ->
                    ( { model | response = val}, Cmd.none )

                Err error ->
                    ( handleError model error, Cmd.none )
    ClickSubmit ->
      (model, testPost model)

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Name" model.name Name
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
    , viewValidation model
    , div [] [ button [onClick ClickSubmit ] [text "Submit"] ]
    , text model.response
    ]
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | response = "bad url: " ++ url }
        Http.Timeout ->
            { model | response = "timeout" }
        Http.NetworkError ->
            { model | response = "network error" }
        Http.BadStatus i ->
            { model | response = "bad status " ++ String.fromInt i }
        Http.BadBody body ->
            { model | response = "bad body " ++ body }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

viewInput : String -> String -> String -> (String -> Msg) -> Html Msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html Msg
viewValidation model =
  if model.password == model.passwordAgain then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]
