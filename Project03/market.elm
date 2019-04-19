import Browser
import Html exposing (..)
import Html.Events exposing(..)
import Html.Attributes exposing (..)
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


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL
type Fruit = Banana|Pineapple

type alias Model =
  { money : Float
  , day : Int
  , fruit : List Fruit
  , price: List Float
  , q1 : Int
  , q2 : Int
  , bas1: Int
  , bas2: Int
  , text: String
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( initmodel
  , Cmd.none
  )

initmodel = { money= 100, day = 1, fruit = [Banana,Pineapple],price=[10,30],q1=0,q2=0,bas1=0,bas2=0,text="Enter Input!"}

-- UPDATE


type Msg
  = NextDay
  | NewPrice (List Float)
  | EnterQuantity Int String
  | Sell Int
  | Buy Int

formList a b = [a,b]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NextDay ->
      ( {model|day=model.day+1}
      , Random.generate NewPrice <| Random.map2  formList (Random.float 0.9 1.11) (Random.float 0.9 1.11)
      )

    NewPrice newprice ->
      ( {model|price= List.map2 (*) model.price newprice }
      , Cmd.none
      )

    EnterQuantity int1 str2 ->
      let
          num = Maybe.withDefault 0 (String.toInt str2)
      in
            case int1 of
                      1 -> ({model|bas1= num,text="..."},Cmd.none)
                      _ -> ({model|bas2= num,text="..."},Cmd.none)


    Sell int ->
      let m1 = (toFloat model.bas1) * (Maybe.withDefault 0 <| List.head model.price)
          m2 = (toFloat model.bas2) * (Maybe.withDefault 0 <| List.head <| List.reverse model.price)
      in
        case int of
            0 -> case model.bas1 > 0 of
                      True -> case model.bas1<=model.q1 of
                                True -> ({model|q1=model.q1-model.bas1,money=model.money+ m1,text="Success!"},Cmd.none)
                                _    -> ({model|text="You do not have enough fruit to sell!"},Cmd.none)
                      _    -> ({model|text="A positive integer!"},Cmd.none)
            _ -> case model.bas2 >0 of
                      True -> case model.bas2<=model.q2 of
                                True -> ({model|q2=model.q2-model.bas2,money=model.money+ m2,text="Success!"},Cmd.none)
                                _    -> ({model|text="You do not have enough fruit to sell!"},Cmd.none)
                      _    -> ({model|text="A positive integer!"},Cmd.none)



    Buy int ->
      let m1 = (toFloat model.bas1) * (Maybe.withDefault 0 <| List.head <| model.price)
          m2 = (toFloat model.bas2) * (Maybe.withDefault 0 <| List.head <| List.reverse model.price)
      in
        case int of
            0 -> case model.bas1 >0 of
                    True -> case m1 <= model.money of
                              True -> ({model|q1=model.q1+model.bas1,money=model.money- m1,text="Success!"},Cmd.none)
                              _    -> ({model|text="You do not have enough money to buy!"},Cmd.none)
                    _   ->  ({model|text="A positive integer!"},Cmd.none)
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
  div []
    [ h1 [] [ text <| "Day " ++ String.fromInt model.day]
    , Grid.container []
       [ CDN.stylesheet
       , Grid.row [Row.middleXs]
          [Grid.col [] [div [style "background-color" "#ff4444"] [ h2 [] [ text "Fruit Price"]
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
          , Grid.col [Col.xs5] [h2 [] [text "Market Place"]
                                , Grid.row []
                                      [Grid.col [] [text "Banana"]
                                      ,Grid.col [Col.xs9] [ Form.formInline []
                                                              [ Input.text [ Input.small,Input.attrs [ placeholder "Quantity" ], Input.onInput <| EnterQuantity 1]
                                                              , ButtonGroup.buttonGroup []
                                                                  [ ButtonGroup.button [ Button.small,Button.info, Button.onClick <| Sell 0 ] [  text "Sell" ]
                                                                  , ButtonGroup.button [ Button.small, Button.info, Button.onClick <| Buy 0 ] [  text "Buy" ]
                                                                  ]
                                                              ]
                                                          ]
                                      ]
                                , Grid.row []
                                      [Grid.col [] [text "Pineapple"]
                                      ,Grid.col [Col.xs9] [ Form.formInline []
                                                              [ Input.text [ Input.small,Input.attrs [ placeholder "Quantity" ], Input.onInput <| EnterQuantity 1]
                                                              , ButtonGroup.buttonGroup []
                                                                  [ ButtonGroup.button [ Button.primary, Button.small, Button.onClick <| Sell 1 ] [  text "Sell" ]
                                                                  , ButtonGroup.button [ Button.secondary, Button.small, Button.onClick <| Buy 1 ] [  text "Buy" ]
                                                                  ]
                                                              ]
                                                          ]
                                      ]
                                ]
          , Grid.col [] [ h2 [] [text "Your Basket"]
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
    , p [] [text model.text]
    , p [] [text <| "money " ++ String.fromFloat model.money]
    , Button.button [ Button.disabled False, Button.onClick NextDay ] [ text "Next Day" ]
    ]
