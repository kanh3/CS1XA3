import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random



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
  , price: Float
  , quantity: List Int
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( initmodel
  , Cmd.none
  )

initmodel = { money= 100, day = 1, fruit = [Banana,Pineapple],price=10,quantity=[0,0]}

-- UPDATE


type Msg
  = NextDay
  | NewPrice  Float


change = let r1 = Random.float 0.9 1.1
             r2 = Random.float 0.9 1.1
         in [ r1, r2]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NextDay ->
      ( {model|day=model.day+1}
      , Random.generate NewPrice <| Random.float 0.9 1.1
      )

    NewPrice newprice ->
      ( {model|price= model.price * newprice}
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text <| String.fromFloat model.price ]
    , button [ onClick NextDay ] [ text "Next Day" ]
    ]
