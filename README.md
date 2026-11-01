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


import dataiku
import pandas as pd

# Read input dataset
input_dataset = dataiku.Dataset("stacked_dataset")
df = input_dataset.get_dataframe()

# Normalize IDs
ids = df["ID"].astype("string").str.strip()

# Identify null, empty, HP and GHS IDs
separate_mask = (
    ids.isna()
    | ids.eq("")
    | ids.str.upper().str.startswith(("HP", "GHS"), na=False)
).fillna(False)

# Output 1: Separated IDs (all retained)
null_ids = df.loc[separate_mask].copy().reset_index(drop=True)

# Work only with valid IDs
valid_df = df.loc[~separate_mask].copy()
valid_df["ID"] = ids.loc[~separate_mask]

# Normalize whitespace and empty values
other_columns = [col for col in valid_df.columns if col != "ID"]

for col in other_columns:
    valid_df[col] = valid_df[col].map(
        lambda x: x.strip() if isinstance(x, str) else x
    )
    valid_df[col] = valid_df[col].replace("", pd.NA)

# Store resolved records and conflicts
resolved_records = []
conflicting_groups = []

# Analyze each ID
for id_value, group in valid_df.groupby("ID", sort=False):

    merged_record = {"ID": id_value}
    conflict_columns = []

    for col in other_columns:

        # Ignore missing values
        values = group[col].dropna()

        # Find distinct non-null values
        unique_values = values.unique()

        if len(unique_values) == 0:
            merged_record[col] = pd.NA

        elif len(unique_values) == 1:
            # Identical or complementary information
            merged_record[col] = unique_values[0]

        else:
            # Different values for the same ID
            conflict_columns.append(col)

    if not conflict_columns:
        # Safe to merge into a single record
        resolved_records.append(merged_record)

    else:
        # Retain every row for manual investigation
        conflict_group = group.copy()
        conflict_group["CONFLICT_COLUMNS"] = ", ".join(
            conflict_columns
        )
        conflicting_groups.append(conflict_group)

# Build output datasets
unique_ids = pd.DataFrame(
    resolved_records,
    columns=valid_df.columns
).reset_index(drop=True)

if conflicting_groups:
    conflicting_ids = pd.concat(
        conflicting_groups,
        ignore_index=True
    )
else:
    conflicting_ids = valid_df.iloc[0:0].copy()
    conflicting_ids["CONFLICT_COLUMNS"] = pd.Series(dtype="string")

# Write outputs
dataiku.Dataset("unique_ids").write_with_schema(unique_ids)
dataiku.Dataset("null_ids").write_with_schema(null_ids)
dataiku.Dataset("conflicting_ids").write_with_schema(conflicting_ids)

# Summary
print(f"Total input rows: {len(df)}")
print(f"Unique resolved IDs: {len(unique_ids)}")
print(f"Separated rows (NULL/HP/GHS): {len(null_ids)}")
print(f"Conflicting IDs: {conflicting_ids['ID'].nunique()}")
print(f"Rows requiring investigation: {len(conflicting_ids)}")
