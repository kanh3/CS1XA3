import Browser
import Browser.Navigation exposing(load)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import String



rootUrl = "http://localhost:8000/e/kanh3/"



--rootUrl = "https://mac1xa3.ca/e/kanh3/"


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
    { username : String, day: Int, value:Float , error : String }


type Msg
    = GotUserinfoResponse (Result Http.Error Model)
    | GotResumeResponse (Result Http.Error String) -- Recieved Success or Failure
    | GotNewResponse (Result Http.Error String)
    | NewGame -- Button to register
    | ResumeGame    -- Button to login
    | LogOut


init : () -> ( Model, Cmd Msg )
init _ =
    ( { username = ""
      , day = 0
      , value = 0
      , error = ""
      }
    , getUserinfo initmodel
    )

initmodel={ username = ""
  , day = 0
  , value = 0
  , error = ""
  }

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
        [
         div []
            [ text <| "Hello username is " ++ model.username
            , text <| "longest day is" ++ String.fromInt model.day
            , text <| "highest value is" ++ String.fromFloat model.value
            , button [ Events.onClick NewGame ] [ text "New Game" ]
            , button [ Events.onClick ResumeGame ] [ text "Resume Game" ]
            , button [ Events.onClick LogOut ] [ text "Logout" ]
            ]
        , div [] [ text model.error ]
        ]


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
        ]

modelDecoder : JDecode.Decoder Model
modelDecoder =
    JDecode.map4 Model
      (JDecode.field "username" JDecode.string)
      (JDecode.field "day" JDecode.int)
      (JDecode.field "value" JDecode.float)
      (JDecode.field "error" JDecode.string)



resumeGame : Model -> Cmd Msg
resumeGame model =
    Http.post
        { url = rootUrl ++ "p3app/resume/"
        , body = Http.jsonBody <| modelEncoder model
        , expect = Http.expectString GotResumeResponse
        }

newGame : Model -> Cmd Msg
newGame model =
    Http.post
        { url = rootUrl ++ "p3app/new/"
        , body = Http.jsonBody <| modelEncoder model
        , expect = Http.expectString GotNewResponse
        }

getUserinfo: Model -> Cmd Msg
getUserinfo model =
    Http.post
        { url = rootUrl ++ "p3app/userinfo/"
        , body = Http.jsonBody <| modelEncoder model
        , expect = Http.expectJson GotUserinfoResponse modelDecoder

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
        GotUserinfoResponse result ->
            case result of
                Ok newmodel ->
                    ( newmodel, Cmd.none )

                Err error ->
                    ( handleError model error, Cmd.none )

        GotResumeResponse result ->
            case result of
                Ok _ ->
                    ( model, load (rootUrl ++ "static/market.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        GotNewResponse result ->
            case result of
                Ok _ ->
                    ( model, load (rootUrl ++ "static/market.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        ResumeGame ->
            ( model, resumeGame model)

        NewGame ->
            ( model, newGame model )

        LogOut ->
            ( model, load ( rootUrl++ "static/user.html") )

--TODO: change url


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
