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

#gestionando el juego
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0
while true; do
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
done

#Implementar el resultado en la base de datos
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ $USER_ID ]]; then
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses, secret_number) VALUES($USER_ID, $NUMBER_OF_GUESSES, $SECRET_NUMBER)")
fi
