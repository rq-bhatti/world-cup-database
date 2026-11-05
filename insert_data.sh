#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Start from a clean slate so the script can be re-run safely
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")"

get_team_id() {
  local NAME="$1"
  local ID
  ID=$($PSQL "SELECT team_id FROM teams WHERE name='$NAME'")
  if [[ -z $ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$NAME')" > /dev/null
    ID=$($PSQL "SELECT team_id FROM teams WHERE name='$NAME'")
  fi
  echo "$ID"
}

CSV_FILE="$(dirname "$0")/games.csv"

tail -n +2 "$CSV_FILE" | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=$(get_team_id "$WINNER")
  OPPONENT_ID=$(get_team_id "$OPPONENT")
  RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $RESULT == "INSERT 0 1" ]]
  then
    echo "Inserted game: $YEAR $ROUND, $WINNER vs $OPPONENT"
  fi
done
