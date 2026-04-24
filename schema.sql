-- Football League Management & Analytics Database
-- Improved version for review: consistent naming, stronger constraints, analytics-ready views.

PRAGMA foreign_keys = ON;

-- =========================
-- Core reference tables
-- =========================
CREATE TABLE players (
    id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    height_m REAL CHECK (height_m > 0),
    weight_kg REAL CHECK (weight_kg > 0),
    nationality TEXT NOT NULL,
    date_of_birth DATE NOT NULL
);

CREATE TABLE teams (
    id INTEGER PRIMARY KEY,
    team_name TEXT NOT NULL UNIQUE,
    coach_name TEXT NOT NULL
);

CREATE TABLE leagues (
    id TEXT PRIMARY KEY,
    league_name TEXT NOT NULL UNIQUE,
    country TEXT NOT NULL,
    number_of_teams INTEGER NOT NULL CHECK (number_of_teams > 0)
);

CREATE TABLE stadiums (
    id INTEGER PRIMARY KEY,
    stadium_name TEXT NOT NULL,
    city TEXT NOT NULL,
    country TEXT NOT NULL,
    capacity INTEGER CHECK (capacity > 0)
);

CREATE TABLE referees (
    id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    country TEXT NOT NULL
);

CREATE TABLE seasons (
    id INTEGER PRIMARY KEY,
    league_id TEXT NOT NULL,
    season_name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (start_date < end_date),
    FOREIGN KEY (league_id) REFERENCES leagues(id) ON DELETE CASCADE
);

-- Teams registered in each league/season.
CREATE TABLE league_teams (
    league_id TEXT NOT NULL,
    season_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    PRIMARY KEY (league_id, season_id, team_id),
    FOREIGN KEY (league_id) REFERENCES leagues(id) ON DELETE CASCADE,
    FOREIGN KEY (season_id) REFERENCES seasons(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);

-- Player membership in teams. This supports historical squads.
CREATE TABLE team_players (
    team_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    player_position TEXT NOT NULL CHECK (player_position IN ('Goalkeeper','Defender','Midfielder','Forward')),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (team_id, player_id, start_date),
    CHECK (end_date IS NULL OR start_date IS NULL OR start_date <= end_date),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE games (
    id INTEGER PRIMARY KEY,
    league_id TEXT NOT NULL,
    season_id INTEGER NOT NULL,
    stadium_id INTEGER NOT NULL,
    referee_id INTEGER NOT NULL,
    home_team_id INTEGER NOT NULL,
    away_team_id INTEGER NOT NULL,
    date_played DATE NOT NULL,
    CHECK (home_team_id <> away_team_id),
    FOREIGN KEY (league_id) REFERENCES leagues(id),
    FOREIGN KEY (season_id) REFERENCES seasons(id),
    FOREIGN KEY (stadium_id) REFERENCES stadiums(id),
    FOREIGN KEY (referee_id) REFERENCES referees(id),
    FOREIGN KEY (home_team_id) REFERENCES teams(id),
    FOREIGN KEY (away_team_id) REFERENCES teams(id)
);

CREATE TABLE game_results (
    game_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    opponent_id INTEGER NOT NULL,
    goals_scored INTEGER NOT NULL CHECK (goals_scored >= 0),
    goals_conceded INTEGER NOT NULL CHECK (goals_conceded >= 0),
    result TEXT GENERATED ALWAYS AS (
        CASE
            WHEN goals_scored > goals_conceded THEN 'win'
            WHEN goals_scored < goals_conceded THEN 'loss'
            ELSE 'draw'
        END
    ) STORED,
    PRIMARY KEY (game_id, team_id),
    CHECK (team_id <> opponent_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id),
    FOREIGN KEY (opponent_id) REFERENCES teams(id)
);

CREATE TABLE player_performances (
    game_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    minutes_played INTEGER NOT NULL DEFAULT 0 CHECK (minutes_played BETWEEN 0 AND 120),
    goals INTEGER NOT NULL DEFAULT 0 CHECK (goals >= 0),
    assists INTEGER NOT NULL DEFAULT 0 CHECK (assists >= 0),
    yellow_cards INTEGER NOT NULL DEFAULT 0 CHECK (yellow_cards BETWEEN 0 AND 2),
    red_cards INTEGER NOT NULL DEFAULT 0 CHECK (red_cards BETWEEN 0 AND 1),
    PRIMARY KEY (game_id, player_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (team_id) REFERENCES teams(id)
);

CREATE TABLE goals (
    id INTEGER PRIMARY KEY,
    game_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    minute INTEGER NOT NULL CHECK (minute BETWEEN 1 AND 130),
    assist_player_id INTEGER,
    goal_type TEXT NOT NULL DEFAULT 'open play' CHECK (goal_type IN ('open play','penalty','free kick','header','own goal')),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (team_id) REFERENCES teams(id),
    FOREIGN KEY (assist_player_id) REFERENCES players(id)
);

CREATE TABLE substitutions (
    game_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    player_out_id INTEGER NOT NULL,
    player_in_id INTEGER NOT NULL,
    minute INTEGER NOT NULL CHECK (minute BETWEEN 1 AND 130),
    PRIMARY KEY (game_id, player_out_id, player_in_id),
    CHECK (player_out_id <> player_in_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id),
    FOREIGN KEY (player_out_id) REFERENCES players(id),
    FOREIGN KEY (player_in_id) REFERENCES players(id)
);

CREATE TABLE player_contracts (
    id INTEGER PRIMARY KEY,
    player_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    transfer_fee REAL DEFAULT 0 CHECK (transfer_fee >= 0),
    CHECK (end_date IS NULL OR start_date <= end_date),
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);

CREATE TABLE player_availability (
    id INTEGER PRIMARY KEY,
    player_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    type TEXT NOT NULL CHECK (type IN ('injury','suspension')),
    description TEXT,
    CHECK (end_date IS NULL OR start_date <= end_date),
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- =========================
-- Indexes for joins, filters, standings and top scorer queries
-- =========================
CREATE INDEX idx_players_name ON players(last_name, first_name);
CREATE INDEX idx_team_players_team ON team_players(team_id);
CREATE INDEX idx_team_players_player ON team_players(player_id);
CREATE INDEX idx_games_league_season ON games(league_id, season_id);
CREATE INDEX idx_games_date ON games(date_played);
CREATE INDEX idx_game_results_team ON game_results(team_id);
CREATE INDEX idx_player_performances_player ON player_performances(player_id);
CREATE INDEX idx_player_performances_team ON player_performances(team_id);
CREATE INDEX idx_goals_player ON goals(player_id);
CREATE INDEX idx_availability_player_dates ON player_availability(player_id, start_date, end_date);

-- =========================
-- Analytics views
-- =========================
CREATE VIEW team_results_summary AS
SELECT
    t.id AS team_id,
    t.team_name,
    gr.result,
    COUNT(*) AS games_count
FROM game_results gr
JOIN teams t ON gr.team_id = t.id
GROUP BY t.id, t.team_name, gr.result;

CREATE VIEW team_standings AS
SELECT
    g.league_id,
    g.season_id,
    t.id AS team_id,
    t.team_name,
    COUNT(gr.game_id) AS games_played,
    SUM(CASE WHEN gr.result = 'win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN gr.result = 'draw' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN gr.result = 'loss' THEN 1 ELSE 0 END) AS losses,
    SUM(gr.goals_scored) AS goals_for,
    SUM(gr.goals_conceded) AS goals_against,
    SUM(gr.goals_scored) - SUM(gr.goals_conceded) AS goal_difference,
    SUM(CASE WHEN gr.result = 'win' THEN 3 WHEN gr.result = 'draw' THEN 1 ELSE 0 END) AS points
FROM game_results gr
JOIN games g ON gr.game_id = g.id
JOIN teams t ON gr.team_id = t.id
GROUP BY g.league_id, g.season_id, t.id, t.team_name
ORDER BY points DESC, goal_difference DESC, goals_for DESC;

CREATE VIEW league_top_scorers AS
SELECT
    g.league_id,
    g.season_id,
    l.league_name,
    p.id AS player_id,
    p.first_name || ' ' || p.last_name AS player_name,
    t.team_name,
    SUM(pp.goals) AS total_goals,
    SUM(pp.assists) AS total_assists,
    SUM(pp.minutes_played) AS total_minutes
FROM player_performances pp
JOIN games g ON pp.game_id = g.id
JOIN players p ON pp.player_id = p.id
JOIN teams t ON pp.team_id = t.id
JOIN leagues l ON g.league_id = l.id
GROUP BY g.league_id, g.season_id, l.league_name, p.id, player_name, t.team_name
ORDER BY g.league_id, g.season_id, total_goals DESC, total_assists DESC;

CREATE VIEW player_card_status AS
SELECT
    pp.game_id,
    p.id AS player_id,
    p.first_name || ' ' || p.last_name AS player_name,
    t.team_name,
    pp.yellow_cards,
    pp.red_cards,
    CASE
        WHEN pp.red_cards > 0 THEN 'red card'
        WHEN pp.yellow_cards >= 2 THEN 'sent off after second yellow'
        WHEN pp.yellow_cards = 1 THEN 'yellow card warning'
        ELSE 'ok'
    END AS card_status
FROM player_performances pp
JOIN players p ON pp.player_id = p.id
JOIN teams t ON pp.team_id = t.id;

CREATE VIEW unavailable_players AS
SELECT
    p.id AS player_id,
    p.first_name || ' ' || p.last_name AS player_name,
    pa.type,
    pa.start_date,
    pa.end_date,
    pa.description
FROM player_availability pa
JOIN players p ON pa.player_id = p.id
WHERE pa.end_date IS NULL OR pa.end_date >= DATE('now');
