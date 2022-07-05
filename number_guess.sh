#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"

read USER_NAME

NUMBER_TO_BE_GUESSED=$(( RANDOM % 1000 + 1 ))

CHECK_USER_EXIST=$($PSQL "SELECT user_id FROM users where username='$USER_NAME'")

typeset -i ATTEMPT=1
USER_NUMBER=-1

is_number () {
  echo $1
  if [[ $1 =~ ^[0-9]+ ]] && ! [[ $1 =~ [a-z,A-Z] ]]
  then 
    echo "came here"
    return 1
  else
    echo "came here else"
    return 0  
  fi  
}

if [[ -z $CHECK_USER_EXIST ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
else
  GAME_STATS=$($PSQL "SELECT COUNT(*),min(number_of_tries) FROM games where user_id=$CHECK_USER_EXIST")
  echo "$GAME_STATS" | while IFS="|" read number_of_games best_score
  do
    echo Welcome back, $USER_NAME! You have played $number_of_games games, and your best game took $best_score guesses.
  done  
fi

USER_ID=$($PSQL "SELECT user_id FROM users where username='$USER_NAME'")
echo "Guess the secret number between 1 and 1000:"
read USER_NUMBER  

is_number "$USER_NUMBER"
if [[ $? -eq 0 ]]
then 
  echo "That is not an integer, guess again:"
  read USER_NUMBER
fi  

while (( NUMBER_TO_BE_GUESSED != USER_NUMBER ))
  do
    #echo "attempt: $ATTEMPT"
    #echo $NUMBER_TO_BE_GUESSED,$USER_NUMBER
    if [[ $NUMBER_TO_BE_GUESSED -gt $USER_NUMBER ]]
    then
      echo "It's higher than that, guess again:" 
      read USER_NUMBER
    else
      echo "It's lower than that, guess again:" 
      read USER_NUMBER
    fi
    ATTEMPT=ATTEMPT+1
  done

echo "You guessed it in $ATTEMPT tries. The secret number was $NUMBER_TO_BE_GUESSED. Nice job!"

INSERT_GAME=$($PSQL "INSERT INTO games(user_id,number_of_tries) VALUES($USER_ID,$ATTEMPT)")
