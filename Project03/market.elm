import Browser
import Browser.Navigation exposing(load)
import Html exposing (..)
import Html.Events exposing(..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import Random
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
-- MAIN

--rootUrl = "http://localhost:8000/e/kanh3/"
rootUrl = "https://mac1xa3.ca/e/kanh3/"


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Model =
  { money : Float
  , day : Int
  , price: List Float
  , q1 : Int  --quantity you have
  , q2 : Int
  , bas1: Int --buy and sell quantity
  , bas2: Int
  , text: String
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( initmodel
  , getGameStatus --new or resume
  )

initmodel = { money= 100, day = 1,price=[10,30],q1=0,q2=0,bas1=0,bas2=0,text="Enter Input!"}

-- UPDATE


type Msg
  = SAQ  -- Save and Quit
  | GotSaveQuitResponse (Result Http.Error String)
  | GotGameStatusResponse (Result Http.Error String)
  | GotDataResponse (Result Http.Error Model)
  | NextDay -- End day
  | NewPrice (List Float) -- Change Price
  | EnterQuantity Int String -- change quantity on input
  | Sell Int -- sell which
  | Buy Int -- buy which

formList a b = [a,b]  -- :: dosen't work

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    -- server side included

    SAQ  ->
      ( model, saveQuit model)

    GotSaveQuitResponse result ->
        case result of
            Ok "SaveFailed" -> -- something is wrong
                ( { model | text = "please try again" }, Cmd.none )

            Ok "LoggedOut" ->
                ( { model | text = "not logged in" }, Cmd.none )

            Ok _ -> --success
                ( model, load (rootUrl++"static/userinfo.html") )

            Err error ->
                ( handleError model error, Cmd.none )

    GotGameStatusResponse result ->
        case result of
            Ok "NewGame" ->
                ( model, Cmd.none )

            Ok "None" -> --?? will this happen?
                ( model, load (rootUrl++"static/userinfo.html") )

            Ok "ResumeGame" ->
                ( model, getData model)

            Ok "Loggedout" ->
                ( model, load (rootUrl++"static/user.html"))

            Ok _  -> -- ??
                ( model, Cmd.none )

            Err error ->
                ( handleError model error, Cmd.none )

    GotDataResponse result -> -- only under resume game
        case result of
            Ok newmodel ->
                (newmodel, Cmd.none)

            Err error ->
                ( handleError model error, Cmd.none )





    ---  from here : No Server Side code included

    NextDay -> -- changes price
      ( {model|day=model.day+1}
      , Random.generate NewPrice <| Random.map2  formList (Random.float 0.9 1.11) (Random.float 0.9 1.11)
      )

    NewPrice newprice -> -- newprice in list form
      ( {model|price= List.map2 (*) model.price newprice }
      , Cmd.none
      )

    EnterQuantity int1 str2 -> -- int1: which fruit, str2:quantity
      let
          num = Maybe.withDefault 0 (String.toInt str2)
      in
            case int1 of
                      1 -> ({model|bas1= num,text="..."},Cmd.none)
                      _ -> ({model|bas2= num,text="..."},Cmd.none)


    Sell int ->
      let m1 = (toFloat model.bas1) * (Maybe.withDefault 0 <| List.head model.price) -- money get selling fruit 1
          m2 = (toFloat model.bas2) * (Maybe.withDefault 0 <| List.head <| List.reverse model.price)
      in
        case int of
            -- fruit 1
            0 -> case model.bas1 > 0 of -- positive
                      True -> case model.bas1<=model.q1 of  -- enough fruit to sell or not
                                True -> ({model|q1=model.q1-model.bas1,money=model.money+ m1,text="Success!"},Cmd.none)
                                _    -> ({model|text="You do not have enough fruit to sell!"},Cmd.none)
                      _    -> ({model|text="A positive integer!"},Cmd.none)
            -- fruit2
            _ -> case model.bas2 >0 of
                      True -> case model.bas2<=model.q2 of
                                True -> ({model|q2=model.q2-model.bas2,money=model.money+ m2,text="Success!"},Cmd.none)
                                _    -> ({model|text="You do not have enough fruit to sell!"},Cmd.none)
                      _    -> ({model|text="A positive integer!"},Cmd.none)



    Buy int ->
      let m1 = (toFloat model.bas1) * (Maybe.withDefault 0 <| List.head <| model.price) -- money paid to buy fruit 1
          m2 = (toFloat model.bas2) * (Maybe.withDefault 0 <| List.head <| List.reverse model.price)
      in
        case int of
            -- fruit 1
            0 -> case model.bas1 >0 of --positive
                    True -> case m1 <= model.money of  -- enough money to buy or not
                              True -> ({model|q1=model.q1+model.bas1,money=model.money- m1,text="Success!"},Cmd.none)
                              _    -> ({model|text="You do not have enough money to buy!"},Cmd.none)
                    _   ->  ({model|text="A positive integer!"},Cmd.none)

            -- fruit 2
            _ -> case model.bas2>0 of
                    True -> case m2 <= model.money of
                              True -> ({model|q2=model.q2+model.bas2,money=model.money- m2,text="Success!"},Cmd.none)
                              _    -> ({model|text="You do not have enough money to buy!"},Cmd.none)
                    _    -> ({model|text="A positive integer!"},Cmd.none)






-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div [class "text-center py-3 " ,style "background-color" "#ffb74d"]
    [ h1 [class "text-center py-3 my-3"] [ text <| "Day " ++ String.fromInt model.day]
    , br [] []
    , Grid.container [class "py-3 my-3", style "height" "280px"] -- grid for price, market, basket
       [ CDN.stylesheet
       , Grid.row []
          [Grid.col [] [div [style "background-color" "#fff59d", style "height" "250px"]
                                [ h2 [] [ text "Fruit Price"] -----------------------
                                , Grid.row []
                                    [Grid.col [] [ text "Banana"]
                                    ,Grid.col [Col.xs8] [ text <| String.fromFloat ( Maybe.withDefault 0 <| List.head model.price) ]
                                    ]
                                , Grid.row []
                                    [Grid.col [] [text "Pineapple"]
                                    ,Grid.col [Col.xs8] [text <| String.fromFloat ( Maybe.withDefault 0 <| List.head <| List.reverse model.price)]
                                    ]
                                ]
                        ]
          , Grid.col [Col.xs5] [div [style "background-color" "#ffe082", style "height" "250px"]
                                [ h2 [] [text "Market Place"] --------------------
                                , Grid.row []
                                      [Grid.col [] [text "Banana"]     ----------buy and sell for fruit 1
                                      ,Grid.col [Col.xs9] [ Form.formInline []
                                                              [ Input.text [ Input.small,Input.attrs [ placeholder "Quantity" ], Input.onInput <| EnterQuantity 1]
                                                              , ButtonGroup.buttonGroup []
                                                                  [ ButtonGroup.button [ Button.small,Button.info, Button.onClick <| Sell 0 ] [  text "Sell" ]
                                                                  , ButtonGroup.button [ Button.small, Button.primary, Button.onClick <| Buy 0 ] [  text "Buy" ]
                                                                  ]
                                                              ]
                                                           ]
                                      ]
                                , Grid.row []
                                      [Grid.col [] [text "Pineapple"]  -----------buy and sell for fruit 2
                                      ,Grid.col [Col.xs9] [ Form.formInline []
                                                              [ Input.text [ Input.small,Input.attrs [ placeholder "Quantity" ], Input.onInput <| EnterQuantity 2]
                                                              , ButtonGroup.buttonGroup []
                                                                  [ ButtonGroup.button [ Button.primary, Button.small, Button.onClick <| Sell 1 ] [  text "Sell" ]
                                                                  , ButtonGroup.button [ Button.info, Button.small, Button.onClick <| Buy 1 ] [  text "Buy" ]
                                                                  ]
                                                              ]
                                                          ]
                                      ]
                                ]
                               ]
          , Grid.col [] [ div [ style "background-color" "#ffcc80", style "height" "250px"]
                        [ h2 [] [text "Your Basket"]  -------------------------------
                        , Grid.row []
                            [Grid.col [] [ text "Banana"]
                            ,Grid.col [] [ text <| String.fromInt model.q1 ]
                            ]
                        , Grid.row []
                            [Grid.col [] [text "Pineapple"]
                            ,Grid.col [] [text <| String.fromInt model.q2]
                            ]
                        ]
                      ]
          ]
        ]
    , p [class "my-3 py-3"] [text model.text] --------hint
    , p [] [text <| "money " ++ String.fromFloat model.money] --------money
    , br [] []
    --------------choice
    , div [] [ Button.button [ Button.warning, Button.onClick NextDay ] [ text "Next Day" ]
             , Button.button [ Button.warning, Button.onClick SAQ ] [ text "Save&Quit"]
             ]
    , br [] []
    ------------background
    , p [] [text <| "Say you are on a tropical island. You make a living by selling and buying fruits."
                ++ " Every day prices change(increase/decrease) up to 10%."
                ++ " You have 100 to start with. Try survive as long as you can while making money."
                ++ " Click on Quantity Box to enter quantity, then press the Buy/Sell Button to buy/sell."
                ++ " Prices are showed on the left and your basket of fruits is showed on the right."
                ++ " When you are ready to end today, click on the NextDay button."
                ++ " If you want to END/PAUSE the game, click on the Save&Quit button."
                ++ " Good luck!"]
    ]


-- post for save&quit, new/resume, getdataforresume

saveQuit : Model -> Cmd Msg
saveQuit model =
    Http.post
        { url = rootUrl ++ "p3app/quit/"
        , body = Http.jsonBody <| modelEncoder model
        , expect = Http.expectString GotSaveQuitResponse
        }

getGameStatus: Cmd Msg
getGameStatus = Http.post {  url = rootUrl ++ "p3app/status/"
                          , body = Http.emptyBody
                          , expect = Http.expectString GotGameStatusResponse
                          }

getData : Model -> Cmd Msg
getData model = Http.post
                  { url = rootUrl ++ "p3app/data/"
                  , body = Http.emptyBody
                  , expect = Http.expectJson GotDataResponse modelDecoder
                  }



-- Json Encode/Decode

modelEncoder : Model -> JEncode.Value
modelEncoder model =
    JEncode.object
        [ ( "money"
          , JEncode.float model.money
          )
        , ( "day"
          , JEncode.int model.day
          )
        , ( "price"
          , JEncode.list JEncode.float model.price
          )
        , ( "q1"
          , JEncode.int model.q1
          )
        , ( "q2"
          , JEncode.int model.q2
          )
        ]

modelDecoder : JDecode.Decoder Model
modelDecoder =
    JDecode.map8 Model
      (JDecode.field "money" JDecode.float)
      (JDecode.field "day" JDecode.int)
      (JDecode.field "price" <| JDecode.list JDecode.float)
      (JDecode.field "q1" JDecode.int)
      (JDecode.field "q2" JDecode.int)
      (JDecode.field "bas1" JDecode.int)
      (JDecode.field "bas2" JDecode.int)
      (JDecode.field "text" JDecode.string)


-- error handling
handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | text = "bad url: " ++ url }

        Http.Timeout ->
            { model | text = "timeout" }

        Http.NetworkError ->
            { model | text = "network error" }

        Http.BadStatus i ->
            { model | text = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | text = "bad body " ++ body }
