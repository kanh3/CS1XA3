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
    { username : String, day: Int, value:Float , error : String }


type Msg
    = GotLogOutResponse (Result Http.Error String)
    | GotUserinfoResponse (Result Http.Error Model)
    | GotResumeResponse (Result Http.Error String) -- Recieved Success or Failure
    | GotNewResponse (Result Http.Error String)
    | NewGame -- Button to start new game
    | ResumeGame    -- Button to resume game
    | LogOut  -- back to loginpage


init : () -> ( Model, Cmd Msg )
init _ =
    ( { username = ""
      , day = 0
      , value = 0
      , error = ""
      }
    , getUserinfo initmodel  -- gets high record
    )

initmodel={ username = ""
  , day = 0
  , value = 0
  , error = ""
  }

view : Model -> Html Msg
view model =
    div []
        [
         div [] [ text <| "Hello " ++ model.username ]
        ,div [] [ text <| "longest day is   " ++ String.fromInt model.day]
        ,div [] [ text <| "highest value is  " ++ String.fromFloat model.value]
        ,div []
            [ button [ Events.onClick NewGame ] [ text "New Game" ]
            , button [ Events.onClick ResumeGame ] [ text "Resume Game" ]
            , button [ Events.onClick LogOut ] [ text "Logout" ]
            ]
        , div [] [ text model.error ]
        ]

--Json Encoder and Decoder
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


-- post for resumegame/newgame/getuserinfo/logout

logOut : Cmd Msg
logOut = Http.post { url = rootUrl ++ "p3app/logout/"
                   , body = Http.emptyBody
                   , expect = Http.expectString GotLogOutResponse
                   }



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


-- update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotLogOutResponse result ->
            case result of
                Ok _  ->
                    (model, load ( rootUrl ++ "static/user.html"))
                Err error ->
                    (handleError model error, Cmd.none)

        GotUserinfoResponse result -> --gets record
            case result of
                Ok newmodel ->
                    ( newmodel, Cmd.none )

                Err error ->
                    ( handleError model error, Cmd.none )

        GotResumeResponse result -> --goes to gamepage
            case result of
                Ok _ ->
                    ( model, load (rootUrl ++ "static/market.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        GotNewResponse result -> --goes to gamepage
            case result of
                Ok _ ->
                    ( model, load (rootUrl ++ "static/market.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        ResumeGame ->
            ( model, resumeGame model)

        NewGame ->
            ( model, newGame model )

        LogOut -> --goes to loginpage
            ( model, logOut )

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
