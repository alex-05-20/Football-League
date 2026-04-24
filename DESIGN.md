# Design Document — Football League Management & Analytics Database

By: TSAPI KOUDJOU Alex Cabrel  
Video overview: <https://youtu.be/BihRbB1wutQ>

## Scope

### Purpose

This database manages and analyzes a football league system. It stores structured information about players, teams, leagues, seasons, matches, match results, player performances, goals, substitutions, stadiums, referees, contracts, and player availability.

The project is designed for both operational use and analytical reporting. It can answer questions such as:

- Which team is leading the league table?
- Who are the top scorers in a league and season?
- Which players are unavailable because of injury or suspension?
- How many goals, cards, assists, wins, draws, and losses have been recorded?
- Which datasets can be reused for dashboards or further sports analytics?

### In scope

- Players and team rosters
- Leagues and seasons
- Games, stadiums, and referees
- Match results and standings
- Player performances
- Goals and substitutions
- Contracts and player availability
- Analytical views for standings, cards, unavailable players, and top scorers

### Outside scope

- Real-time match event streaming
- Ticket sales, fan engagement, sponsorship, and broadcasting
- Detailed financial accounting beyond basic transfer fees
- Advanced match statistics such as xG, possession, pass maps, or pressing metrics
- Predictive models and automated scouting recommendations

## Functional Requirements

Users should be able to:

- Add, update, and delete players, teams, games, and related entities
- Assign players to teams and track roster history
- Record match results for both teams in a game
- Record player-level match performance
- Track goals, assists, cards, injuries, suspensions, and substitutions
- Generate league standings automatically from match results
- Identify top scorers and disciplinary status
- Query unavailable players
- Use views to support dashboards and recurring analytics

The database does not handle live match updates or machine learning predictions directly. However, the schema is structured so that its outputs can feed future analytics or BI tools.

## Representation

### Main entities

#### `players`
Stores player identity and physical profile: name, nationality, height, weight, and date of birth.

#### `teams`
Stores club information, including team name and coach.

#### `leagues`
Stores league information such as league name, country, and number of teams.

#### `seasons`
Links a league to a specific season period.

#### `league_teams`
Associates teams with a league and a season. This avoids assuming that teams remain in the same league every year.

#### `team_players`
Associates players with teams and positions. The table supports start and end dates to represent historical squads.

#### `games`
Stores each match, including league, season, stadium, referee, home team, away team, and date.

#### `game_results`
Stores one row per team per game. A match therefore has two result rows, allowing standings to be calculated easily.

#### `player_performances`
Stores match-level statistics by player: minutes, goals, assists, yellow cards, and red cards.

#### `goals`
Stores goal events, including scorer, team, minute, assist player, and goal type.

#### `substitutions`
Stores substitution events by game, team, minute, player out, and player in.

#### `player_contracts`
Stores contract periods and transfer fees.

#### `player_availability`
Stores injuries and suspensions.

### Key relationships

- A league has many seasons.
- A season contains many teams through `league_teams`.
- A team has many players through `team_players`.
- A game belongs to one league and one season.
- A game has one home team and one away team.
- A game has two result rows in `game_results`.
- A player can have many performances, goals, contracts, and availability records.

## Design Decisions

### Stronger data integrity

The improved schema uses:

- Primary keys on all entities
- Foreign keys to enforce valid relationships
- Composite keys for bridge tables and match-level entities
- `CHECK` constraints for business rules such as non-negative goals, valid card counts, valid player positions, and valid availability types
- Generated columns for match result classification (`win`, `draw`, `loss`)

### Consistent naming

Column names use `snake_case` consistently. This avoids errors caused by mixed capitalization or spaces in column names.

### Analytics-ready structure

The database includes views that support common analytical needs:

- `team_standings`
- `league_top_scorers`
- `team_results_summary`
- `player_card_status`
- `unavailable_players`

These views make the project stronger for a data-oriented review because they show how the database supports BI and sports analytics use cases.

## Optimizations

Indexes are created on common join and filter columns:

- Player and team lookup columns
- Game league/season/date columns
- Team and player IDs in bridge tables
- Player performance and goal tables
- Availability date ranges

These indexes improve the performance of joins and analytical queries, especially standings, player statistics, and availability checks.

## Limitations

- No real-time data ingestion
- No advanced event tracking such as possession, pass networks, xG, shot maps, or pressure metrics
- No predictive analytics layer yet
- No user authentication or application layer
- No automated ETL pipeline yet
- Transfer and salary management are simplified

## Future Improvements

To make the project more impressive for a data scientist, the next steps would be:

1. Add a small seed dataset to demonstrate realistic queries.
2. Connect the SQL database to Python for exploratory analysis.
3. Build a Power BI or Streamlit dashboard for standings, top scorers, player availability, and match trends.
4. Add advanced football metrics such as xG, shots, passes, possession, and player ratings.
5. Add a simple prediction module for match outcome or player performance.
6. Create a data quality report checking missing values, duplicate players, inconsistent match results, and invalid squad records.

