# SQL Murder Mystery — Solution

A step-by-step SQL walkthrough solving the classic “murder in SQL City (Jan 15, 2018)” puzzle using relational queries only.  
This repo contains my annotated SQL queries and reasoning. It does **not** include the database file—bring your own copy of the puzzle DB.

## What this solves
- **Crime**: Murder in **SQL City** on **2018-01-15**  
- **Outcome**:
  - **Murderer**: Jeremy Bowers  
  - **Mastermind**: Miranda Priestly

## How to run
1. Obtain the puzzle database file (e.g., `sql-murder-mystery.db`) compatible with SQLite or load it into your SQL engine.
2. Run the queries interactively, or execute the full script:
   ```bash
   # SQLite example
   sqlite3 sql-murder-mystery.db < sql/solution.sql
