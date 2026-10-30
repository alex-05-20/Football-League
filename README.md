# ⚽ Football League Database

## 📌 Overview
This project is a relational database system designed to manage and analyze a football league.

It demonstrates:
- SQL & data modeling skills
- Scalable database design
- Analytics-ready structure

---

## 🎯 Objectives
- Model a real-world football system
- Ensure data integrity
- Enable analytical queries
- Prepare for future data science use

---

## 🗂️ Database Structure

### Core Entities
- Players
- Teams
- Leagues
- Games
- Player Performances
- Game Results

### Additional Entities
- Contracts
- Availability (injuries/suspensions)
- Goals & Substitutions
- Stadiums & Referees
- Seasons

---

## 🔗 Entity Relationship Diagram
![ER Diagram](football_league_er_diagram.png)

---

## ⚙️ Features

### Data Management
- Insert / update / delete
- Referential integrity (foreign keys)

### Analytics
- League standings
- Top scorers
- Player performance
- Team summaries

---

## 🛠️ Tech Stack
- SQL (PostgreSQL / MySQL)
- Relational modeling

---

## 📂 Structure
/project
- schema.sql
- queries.sql
- DESIGN.md
- README.md
- diagram.png

---

## ▶️ Usage

Create database:
CREATE DATABASE football_league;

Run schema:
psql -d football_league -f schema.sql

Run queries:
psql -d football_league -f queries.sql

---

## 🚧 Limitations
- No real-time updates
- Limited advanced stats
- No ML yet

---

## 🔮 Future Work
- Advanced metrics (xG)
- ETL pipelines
- Dashboards
- Machine learning

---

## 👤 Author
Alex Cabrel Tsapi Koudjou
GitHub: https://github.com/alex-05-20
