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



--rootUrl = "http://localhost:8000/e/kanh3/"



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


stylesheet = node "link" [attribute "rel" "stylesheet",
                          href "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"]
                          []

view : Model -> Html Msg
view model =
    div [ class "container text-center bg-light pt-5 mt-5" ]
        [ stylesheet
        , br [] []
        , h2 [] [ text "Please sign in or register"]
        , br [] []
        , div [ class "text-center rounded"]
            [
             viewInput "text" "UserName" model.username EnterName
            ]
        , div [class ""]
            [
             viewInput "password" "Password" model.password EnterPassword
            ]
        , br [] []
        , div [class " text-center "]
            [ button [ Events.onClick RegisterUser, class "btn btn-outline-primary px-md-4"] [ text "Register" ]
            , button [ Events.onClick LoginUser, class "btn btn-outline-primary px-md-4"] [ text "Login" ]
            ]
        , br [] []
        , div [class "alert alert-primary"] [ text model.error ]
        ]


viewInput : String -> String -> String -> (String -> Msg) -> Html Msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, Events.onInput toMsg ] []


-- Json Encode username and password
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


-- post for login/register button

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



--update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterName name -> -- change username on input
            ({model|username=name},Cmd.none)

        EnterPassword password ->
            ({model|password=password},Cmd.none)

        GotRegisterResponse result -> -- register cases: userexists, success, and error actually
            case result of
                Ok "UserExists" ->
                    ( {model|error="user already exists"}, Cmd.none )

                Ok "LoggedOut" ->
                    ( {model|error=""}, Cmd.none)

                Ok _ ->
                    ( model, load (rootUrl++"static/userinfo.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        GotLoginResponse result -> -- login cases: loginfailed, success, and error
            case result of
                Ok "LoginFailed" ->
                    ( { model | error = "incorrect username or password" }, Cmd.none )

                Ok _ ->
                    ( model, load (rootUrl++"static/userinfo.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        RegisterUser ->  --post
            ( model, registerUser model)

        LoginUser -> --post
            ( model, loginUser model )

--TODO:change url

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
