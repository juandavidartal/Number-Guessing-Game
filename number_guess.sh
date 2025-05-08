#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"



#Prompt message "Enter your username:"
echo -e "Enter your username:"

read USER_INPUT

USERNAME=$($PSQL "SELECT username FROM number_guess WHERE username LIKE '$USER_INPUT'")

#check if username is not registered

if [[ -z $USERNAME ]]
then
  #New user registration
  INSERT_USERNAME=$($PSQL "INSERT INTO number_guess (username) VALUES ('$USER_INPUT')")
  USERNAME=$($PSQL "SELECT username FROM number_guess WHERE username LIKE '$USER_INPUT'")
  #Message for new user
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else #User registered
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE username LIKE '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_score FROM number_guess WHERE username LIKE '$USERNAME'")

  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

#random number generation between 0 and 1000
RANDOM_NUMBER=$((RANDOM % 1001))
echo $RANDOM_NUMBER


echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS
#Integer input validation
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read USER_GUESS
done

#Game Logic
COUNTER=1
while (( $USER_GUESS != $RANDOM_NUMBER ))
do
  if (( $USER_GUESS < $RANDOM_NUMBER ))
  then
    echo -e "It's higher than that, guess again:"
  else
    echo -e "It's lower than that, guess again:"
  fi
  
  COUNTER=$((COUNTER + 1))

  read USER_GUESS
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
done

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE number_guess SET games_played = games_played + 1 WHERE username LIKE '$USERNAME'")

#Get best_game
BEST_GAME=$($PSQL "SELECT best_score FROM number_guess WHERE username LIKE '$USERNAME'")

if [[ -z $BEST_GAME ]] || (( $COUNTER < $BEST_GAME ))
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE number_guess SET best_score = $COUNTER WHERE username LIKE '$USERNAME'")
fi

echo -e "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"
