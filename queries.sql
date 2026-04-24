-- Football League Management & Analytics Database
-- Review-ready queries: CRUD + analytics + operational reporting.

-- 1. List all players with clean profile information.
SELECT id, first_name, last_name, nationality, height_m, weight_kg, date_of_birth
FROM players
ORDER BY last_name, first_name;

-- 2. Show the current squad of a team.
SELECT
    t.team_name,
    p.first_name || ' ' || p.last_name AS player_name,
    tp.player_position,
    tp.start_date
FROM team_players tp
JOIN teams t ON tp.team_id = t.id
JOIN players p ON tp.player_id = p.id
WHERE tp.team_id = 1
  AND (tp.end_date IS NULL OR tp.end_date >= DATE('now'))
ORDER BY tp.player_position, player_name;

-- 3. Upcoming or historical games for one league.
SELECT
    g.id,
    l.league_name,
    ht.team_name AS home_team,
    at.team_name AS away_team,
    s.stadium_name,
    g.date_played
FROM games g
JOIN leagues l ON g.league_id = l.id
JOIN teams ht ON g.home_team_id = ht.id
JOIN teams at ON g.away_team_id = at.id
JOIN stadiums s ON g.stadium_id = s.id
WHERE g.league_id = 'EPL'
ORDER BY g.date_played DESC;

-- 4. League standings for a season.
SELECT *
FROM team_standings
WHERE league_id = 'EPL' AND season_id = 1
ORDER BY points DESC, goal_difference DESC, goals_for DESC;

-- 5. Top scorers in a league and season.
SELECT player_name, team_name, total_goals, total_assists, total_minutes
FROM league_top_scorers
WHERE league_id = 'EPL' AND season_id = 1
ORDER BY total_goals DESC, total_assists DESC
LIMIT 10;

-- 6. Players unavailable today due to injury or suspension.
SELECT player_name, type, start_date, end_date, description
FROM unavailable_players
ORDER BY type, player_name;

-- 7. Team disciplinary summary.
SELECT
    t.team_name,
    SUM(pp.yellow_cards) AS yellow_cards,
    SUM(pp.red_cards) AS red_cards
FROM player_performances pp
JOIN teams t ON pp.team_id = t.id
GROUP BY t.id, t.team_name
ORDER BY red_cards DESC, yellow_cards DESC;

-- 8. Insert a new player and assign him to a team.
INSERT INTO players (id, first_name, last_name, height_m, weight_kg, nationality, date_of_birth)
VALUES (101, 'Lionel', 'Messi', 1.70, 72, 'Argentina', '1987-06-24');

INSERT INTO team_players (team_id, player_id, player_position, start_date)
VALUES (1, 101, 'Forward', DATE('now'));

-- 9. Insert a game and the two mirrored result rows required for standings.
INSERT INTO games (id, league_id, season_id, stadium_id, referee_id, home_team_id, away_team_id, date_played)
VALUES (201, 'EPL', 1, 10, 5, 1, 2, '2025-09-20');

INSERT INTO game_results (game_id, team_id, opponent_id, goals_scored, goals_conceded)
VALUES
    (201, 1, 2, 3, 1),
    (201, 2, 1, 1, 3);

-- 10. Insert player performance for a match.
INSERT INTO player_performances (game_id, player_id, team_id, minutes_played, goals, assists)
VALUES (201, 101, 1, 90, 2, 1);

-- 11. Update player information.
UPDATE players
SET weight_kg = 74
WHERE id = 101;

-- 12. Register an injury or suspension.
INSERT INTO player_availability (player_id, start_date, end_date, type, description)
VALUES (101, '2025-10-01', '2025-10-14', 'injury', 'Minor muscle injury');

-- 13. Remove test data in dependency-safe order.
DELETE FROM player_availability WHERE player_id = 101;
DELETE FROM player_performances WHERE game_id = 201 AND player_id = 101;
DELETE FROM game_results WHERE game_id = 201;
DELETE FROM games WHERE id = 201;
DELETE FROM team_players WHERE team_id = 1 AND player_id = 101;
DELETE FROM players WHERE id = 101;
