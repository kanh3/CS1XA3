module User exposing (main)

import Browser
import Browser.Navigation exposing(load)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http 
import Json.Decode as JDecode
import Json.Encode as JEncode
import String



--rootUrl =
  --  "http://localhost:8000/e/kanh3/"



rootUrl = "https://mac1xa3.ca/e/kanh3/"


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



{- -------------------------------------------------------------------------------------------
   - Model
   --------------------------------------------------------------------------------------------
-}


type alias Model =
    { username : String, password : String , error : String }


type Msg
    = GotLoginResponse (Result Http.Error String) -- Recieved Success or Failure
    | GotRegisterResponse (Result Http.Error String)
    | RegisterUser -- Button to register
    | LoginUser    -- Button to login
    | EnterName String -- Name text field is changed
    | EnterPassword String -- Password text field is changed


init : () -> ( Model, Cmd Msg )
init _ =
    ( { username = ""
      , password = ""
      , error = ""
      }
    , Cmd.none
    )



{- -------------------------------------------------------------------------------------------
   - View
   -   Model Attributes Used:
   -        model.get_response
   -        model.post_response
   -        model.error_repsonse
   -   Messages Used:
   -        onClick GetButton
   -        onClick PostButton
   --------------------------------------------------------------------------------------------
-}


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ viewInput "text" "Name" model.username EnterName
            , viewInput "password" "Password" model.password EnterPassword
            ]
        , div []
            [ text <| "Hello username is " ++ model.username ++ " and password" ++  model.password
            , button [ Events.onClick RegisterUser ] [ text "Register" ]
            , button [ Events.onClick LoginUser ] [ text "Login" ]
            ]
        , div [] [ text model.error ]
        ]

viewInput : String -> String -> String -> (String -> Msg) -> Html Msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, Events.onInput toMsg ] []

{- -------------------------------------------------------------------------------------------
   - JSON Encode/Decode
   -   modelEncoder turns a model into a JSON value that can be used with Http.jsonBody
   -   modelDecoder is used by Http.expectJson to parse a JSON body into a Model
   --------------------------------------------------------------------------------------------
-}


modelEncoder : Model -> JEncode.Value
modelEncoder model =
    JEncode.object
        [ ( "username"
          , JEncode.string model.username
          )
        , ( "password"
          , JEncode.string model.password
          )
        ]


loginUser : Model -> Cmd Msg
loginUser model =
    Http.post
        { url = rootUrl ++ "p3app/login/"
        , body = Http.jsonBody <| modelEncoder model
        , expect = Http.expectString GotLoginResponse
        }


registerUser : Model -> Cmd Msg
registerUser model =
    Http.post
        { url = rootUrl ++ "p3app/register/"
        , body = Http.jsonBody <| modelEncoder model
        , expect = Http.expectString GotRegisterResponse
        }



{- -------------------------------------------------------------------------------------------
   - Update
   -   JSONResponse updates the entire model with the JSON object given by the server
   -   ButtonPressed sends a Http Post using a JSON encoded current model
   --------------------------------------------------------------------------------------------
-}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterName name ->
            ({model|username=name},Cmd.none)

        EnterPassword password ->
            ({model|password=password},Cmd.none)

        GotRegisterResponse result ->
            case result of
                Ok "UserExists" ->
                    ( {model|error="user already exists"}, Cmd.none )
                Ok _ ->
                    ( model, load (rootUrl ++ "static/userinfo.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        GotLoginResponse result ->
            case result of
                Ok "LoginFailed" ->
                    ( { model | error = "failed to login" }, Cmd.none )

                Ok _ ->
                    ( model, load (rootUrl ++ "static/userinfo.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        RegisterUser ->
            ( model, registerUser model)

        LoginUser ->
            ( model, loginUser model )



-- put error message in model.error_response (rendered in view)


handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }

        Http.Timeout ->
            { model | error = "timeout" }

        Http.NetworkError ->
            { model | error = "network error" }

        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error = "bad body " ++ body }
