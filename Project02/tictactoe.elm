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
                   , step: Int
                   , win : Result
                   , counter: Int
                   , scoreX: Int
                   , scoreO: Int
                   , colorX: String
                   , colorO: String}

type Player = X|O|None

type Msg = PlayAgain
          |GivePosition Int
          |CheckWin
          |NewGame
          |StartGame
          |ChangeColor Player String

type Result= Setting|Start|Win|Tie

init : () -> (Model, Cmd Msg)
init _ = ( initModel , Cmd.none )


initModel : Model
initModel = {grid = fromList [None,None,None,None,None,None,None,None,None]
            , player = X
            , text = ""
            , step = 0
            , win = Setting
            , counter = 0
            , scoreX=0
            , scoreO=0
            , colorX="tomato"
            , colorO="tomato"}

countToPlayer: Int -> Player
countToPlayer c = case modBy 2 c of
                    0 -> O
                    1 -> X
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
                        Tie -> "Tie"
                        Win -> case model.player of
                                          X -> "O wins"
                                          O -> "X wins"
                                          _ -> " "
                        _ -> ""

removeMaybe : Maybe Player -> Player
removeMaybe player = case player of
                            Just X -> X
                            Just O -> O
                            Just None -> None
                            Nothing -> None


-- View
view : Model -> Html Msg
view model = case model.win of
                      Setting -> setview model
                      _   -> playview model

playview model =
            let
                    s =style "background-color" <| changeColor model
            in
              div []
                 [ stylesheet
                 , h1 [class "header"] [text "TicTacToe"]

                 , div [ class "container"]
                           [ div [ onClick (GivePosition 0), s] [text (convertPlayer model 0)]
                           , div [ onClick (GivePosition 1), s] [text (convertPlayer model 1)]
                           , div [ onClick (GivePosition 2), s] [text (convertPlayer model 2)]

                           , div [ onClick (GivePosition 3),s] [text (convertPlayer model 3)]
                           , div [ onClick (GivePosition 4),s] [text (convertPlayer model 4)]
                           , div [ onClick (GivePosition 5),s] [text (convertPlayer model 5)]

                           , div [ onClick (GivePosition 6),s] [text (convertPlayer model 6)]
                           , div [ onClick (GivePosition 7),s] [text (convertPlayer model 7)]
                           , div [ onClick (GivePosition 8),s] [text (convertPlayer model 8)]

                           ]
                 , div [ class "button"] [ button [ onClick NewGame] [ text "New Game"]
                                          ,button [ onClick PlayAgain] [text "Play Again"]]
                 , div [class "text"] [ text <| convertText model]
                 , div [class "text"] [text <| convertWin model]
                 , div [class "text"]
                            [ div [] [text <|"X:"++ String.fromInt model.scoreX]
                            , div [] [text <|"O:"++ String.fromInt model.scoreO]
                            , div [] [text <|"Total:" ++ String.fromInt model.counter]
                            ]
                 ]

setview model = div []
                  [ stylesheet
                  , h1 [class "header"] [text "TicTacToe"]
                  , div [class "text"] [text "Choose a color for X"]
                  , div [class "button"] [ button [onClick (ChangeColor X "red")] [text "red"]
                                          ,button [onClick (ChangeColor X "green")] [text "green"]
                                          ,button [onClick (ChangeColor X "blue")] [text "blue"]
                                          ]
                  , div [class "text"] [text "Choose a color for O"]
                  , div [class "button"] [button [onClick (ChangeColor O "yellow")] [text "yellow"]
                                         ,button [onClick (ChangeColor O "grey")] [text "grey"]
                                         ,button [onClick (ChangeColor O "brown")] [text "brown"]
                                         ]
                  , div [class "button"] [button [onClick StartGame] [text "Start Game"]]
                  ]

-- Update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                      StartGame -> ({model|win=Start}, Cmd.none)
                      ChangeColor X colour -> ({model|colorX= colour},Cmd.none)
                      ChangeColor _ colour -> ({model|colorO= colour},Cmd.none)
                      NewGame  -> (initModel, Cmd.none)
                      GivePosition int -> checkModel int model |> update CheckWin
                      CheckWin -> (checkWin model ,Cmd.none)
                      PlayAgain -> ({model|grid=fromList [None,None,None,None,None,None,None,None,None]
                                           , player = countToPlayer model.counter
                                           , step = 0
                                           , win = Start
                                           , counter=model.counter+1},Cmd.none)

changeColor: Model -> String
changeColor model = case model.win of
                              Win -> case model.player of
                                                O -> model.colorX
                                                _ -> model.colorO
                              Tie -> "white"
                              _   -> "tomato"

checkModel : Int -> Model -> Model
checkModel int model =
    case model.win of
      Start ->
          let who = get int model.grid
          in case who of
              Just None -> {model|grid=set int model.player model.grid
                                 ,player=changePlayer model.player
                                 ,step=model.step+1}
              Just _    -> model -- if grid has already been taken then no change
              Nothing   -> model

      _ -> model   --  End game, no change

checkWin : Model -> Model
checkWin model= case model.win of
                      Start ->
                        let
                            list = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
                            s = List.sum <| List.map (listPosToInt model) list
                        in case s of
                                -- no 0 , all 1, no player wins
                                8 -> case model.step of
                                    9 -> {model|win=Tie}  -- last step, should end game
                                    _ -> model           -- game is continuing
                                -- there is at least 1 zero; there is a winner no matter no many steps s/he takes
                                _ -> case model.player of
                                    O -> {model|win = Win, scoreX=model.scoreX+1}
                                    X -> {model|win = Win, scoreO=model.scoreO+1}
                                    _ -> {model|win = Win}
                      _ -> model

listPosToInt :  Model -> List Int ->Int
listPosToInt model list =
            let
                -- map getPlayer to all the position in list
                l= List.map getPlayer list
                -- if player of that position == current player then 0 else 1
                getPlayer int = if (get int model.grid |> removeMaybe) ==  changePlayer model.player then 0 else 1
                -- if and only if all positions on line are claimed by current player then sum of list = 0
            in if List.sum l == 0 then 0 else 1


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
