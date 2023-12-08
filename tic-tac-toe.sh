#!/bin/bash

board=(1 2 3 4 5 6 7 8 9)
current_move=10
move_amount=0
player="X"
new_game=1
game_file="tic-tac-toe.txt"
ai=0

save_game() {
  printf "%s" "${board[@]}" >$game_file
  echo "$player$ai" >>$game_file
  echo "Saved!"
}

load_game() {
  read -r -n 11 loaded_board <"$game_file"

  for ((i = 0; i < 9; i++)); do
    board[i]="${loaded_board:i:1}"
  done

  player="${loaded_board:9:1}"
  ai="${loaded_board:10:1}"
}

reset_game() {
  board=(1 2 3 4 5 6 7 8 9)
  current_move=10
  move_amount=0
  new_game=1
}

draw_board() {
  clear
  echo " ${board[0]} | ${board[1]} | ${board[2]} "
  echo "-----------"
  echo " ${board[3]} | ${board[4]} | ${board[5]} "
  echo "-----------"
  echo " ${board[6]} | ${board[7]} | ${board[8]} "
}
win() {
  draw_board
  echo -e "Congratulations player $1! You won"
  exit 0
}

check_win_by_index() {

  local player=${board[current_move - 1]}

  local row=$(((current_move - 1) / 3 * 3))
  if [[ "${board[$row]}" == "$player" && "${board[$row + 1]}" == "$player" && "${board[$row + 2]}" == "$player" ]]; then
    win "$player"
  fi

  local col=$((((current_move - 1)) % 3))
  if [[ "${board[$col]}" == "$player" && "${board[$col + 3]}" == "$player" && "${board[$col + 6]}" == "$player" ]]; then
    win "$player"
  fi

  if [[ "${board[0]}" == "$player" && "${board[4]}" == "$player" && "${board[8]}" == "$player" ]]; then
    win "$player"
  fi

  if [[ "${board[2]}" == "$player" && "${board[4]}" == "$player" && "${board[6]}" == "$player" ]]; then
    win "$player"
  fi

}

make_move_ai() {
  echo "I'm thinking..."
  sleep 1
  for i in {0..9}; do
    if [[ "${board[i]}" != "X" && "${board[i]}" != "O" ]]; then
      board[i]=$1
      current_move=$((i + 1))
      return
    fi
  done
}
make_move() {

  local move
  local player=$1
  read -rp "Player $player, enter the field number (1-9):" move

  if [[ $move == "save" ]]; then

    save_game
    make_move "$player"

  elif [[ ! $move =~ ^[0-9]+$ || $move -lt 1 || $move -gt 9 ]]; then

    echo "Incorrect move, there is no field $move"
    make_move "$player"

  elif [[ ${board[$move - 1]} == 'X' || ${board[$move - 1]} == 'O' ]]; then

    echo "Incorrect move, this field is already taken!"
    make_move "$player"

  else

    board[$move - 1]=$player
    current_move=$move

  fi

}

draw() {
  echo "Draw! Let's start from the beginning"
}

change_player() {
  if [[ $player == "X" ]]; then
    player="O"
  else
    player="X"
  fi
}
while true; do
  if [ $new_game == 1 ]; then
    new_game=0
    echo -e "Welcome to the Tic-Tac-Toe game! Choose what you would like to do by selecting the corresponding number on the keyboard:\n"
    echo "1 - Start a new game against the computer"
    echo "2 - Load a saved game"
    echo "3 - Play a game against another player"
    echo "4 (or any other) - Quit the program"
    echo "If you want to save a game, instead of selecting a field please type \"save\""
    read -r main_option
  fi

  if [ "$main_option" == "1" ]; then

    ai=1
    draw_board

    if [ "$player" == "X" ]; then
      make_move $player
    else
      make_move_ai $player
    fi

    check_win_by_index
    move_amount=$((move_amount + 1))

    if [ $move_amount == 9 ]; then
      draw_board
      draw
      reset_game
    fi

    change_player

  elif [[ "$main_option" == "2" ]]; then

    load_game

    if [ "$ai" == 1 ]; then
      main_option=1
    else
      main_option=3
    fi

  elif [[ "$main_option" == "3" ]]; then

    ai=0
    draw_board
    make_move $player
    check_win_by_index
    move_amount=$((move_amount + 1))

    if [ $move_amount == 9 ]; then

      draw_board
      draw
      reset_game

    fi

    change_player

  else
    exit 0
  fi

done
