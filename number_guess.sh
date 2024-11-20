#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Solicitar y gestionar en nombre de usuario
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME

# Buscar usuario en la base de datos
USER_INFO=$($PSQL "SELECT user_id, COUNT(game_id) AS games_played, MIN(guesses) AS best_game FROM users LEFT JOIN games USING(user_id) WHERE username='$USERNAME' GROUP BY user_id")

# Si el usuario existe
if [[ $USER_INFO ]]; then
  echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
# Si no existe
else
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi
