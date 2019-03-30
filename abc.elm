import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Array exposing (..)

stylesheet = node "link" [attribute "rel" "stylesheet",
                          href "stylesheet.css"]
                          []

main = Browser.element { init = init, update = update,
                  subscriptions = subscriptions, view = view }

-- Model
type alias Model = { grid : Array Player
                   , player : Player
                   , text: String
                   , counter: Int
                   , step: Int
                   , win : Result}

type Player = X|O|None

type Msg = PlayAgain
          |GivePosition Int
          |CheckWin

type Result= Start|Win|Tie

init : () -> (Model, Cmd Msg)
init _ = ( initModel , Cmd.none )


initModel : Model
initModel = {grid = fromList [None,None,None,None,None,None,None,None,None]
            , player = countToPlayer 0
            , text = "X's turn"
            , counter = 0
            , step = 0
            , win = Start}

countToPlayer: Int -> Player
countToPlayer c = case modBy 2 c of
                    0 -> X
                    1 -> O
                    _ -> None

changePlayer: Player -> Player
changePlayer player = case player of
                        X -> O
                        O -> X
                        None -> X

convertPlayer: Model -> Int -> String
convertPlayer model int = case get int model.grid of
                            Just X -> "X"
                            Just O -> "O"
                            Just None -> ""
                            Nothing -> ""

convertText: Model -> String
convertText model = case model.win of
                    Start -> case model.player of
                                    X -> "X's turn"
                                    O -> "O's turn"
                                    None -> " "
                    _ -> "End"

convertWin: Model -> String
convertWin model = case model.win of
                        Start -> "..."
                        Tie -> "tie"
                        Win -> case model.player of
                                          X -> "O wins"
                                          O -> "X wins"
                                          _ -> " "

removeMaybe : Maybe Player -> Player
removeMaybe player = case player of
                            Just X -> X
                            Just O -> O
                            Just None -> None
                            Nothing -> None

-- View
view : Model -> Html Msg
view model = div []
                 [ stylesheet
                 , h1 [] [text "TicTacToe"]

                 , div [ class "container"]
                           [ div [ class "col", onClick (GivePosition 0)] [text (convertPlayer model 0)]
                           , div [ class "col", onClick (GivePosition 1)] [text (convertPlayer model 1)]
                           , div [ class "col", onClick (GivePosition 2)] [text (convertPlayer model 2)]

                           , div [ class "col", onClick (GivePosition 3)] [text (convertPlayer model 3)]
                           , div [ class "col", onClick (GivePosition 4)] [text (convertPlayer model 4)]
                           , div [ class "col", onClick (GivePosition 5)] [text (convertPlayer model 5)]

                           , div [ class "col", onClick (GivePosition 6)] [text (convertPlayer model 6)]
                           , div [ class "col", onClick (GivePosition 7)] [text (convertPlayer model 7)]
                           , div [ class "col", onClick (GivePosition 8)] [text (convertPlayer model 8)]

                           ]
                 , div [ class "button"] [ button [ onClick PlayAgain] [ text "Play Again"]]
                 , div [] [ text <| convertText model]
                 , div [] [text <| convertWin model]
                 ]

-- Update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                      PlayAgain  -> (initModel, Cmd.none)
                      GivePosition int -> checkModel int model |> update CheckWin
                      CheckWin -> (checkWin model ,Cmd.none)


checkModel : Int -> Model -> Model
checkModel int model =
    case model.win of
      Start ->
          let who = get int model.grid
          in case who of
              Just None -> {model|grid=set int model.player model.grid
                             ,player=changePlayer model.player

                             ,step=model.step+1}


              Just _    -> model
              Nothing   -> model

      _ -> model

checkWin : Model -> Model
checkWin model= let
                    list = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
                    s = List.sum <| List.map (listPosToInt model) list
                in case s of
                      8 -> case model.step of
                                    9 -> {model|win=Tie}
                                    _ -> model
                      _ -> {model|win = Win}


listPosToInt :  Model -> List Int ->Int
listPosToInt model list =
            let
                l= List.map getPlayer list
                getPlayer int = if (get int model.grid |> removeMaybe) ==  changePlayer model.player then 0 else 1
            in if List.sum l == 0 then 0 else 1

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
