# The Interplanetary Lobbing League

Welcome to the Expensive Hardware Lob League. The league covers expensive hardware lob matches held between planets in the Solar System. Two dwarf planets have recently been admitted to the league and lost their first matches against league champions Team Earth.

This repository is to provide the data behind the league and allow others to contribute.

## Matches

The matches are stored in [matches.csv](matches.csv). The format is one __match__ per line. A match is considered to be a mission visiting a planet (includes dwarf planets).

Each row consists of:

  * Launch date - ISO8601 format
  * Name
  * COSPAR ID
  * End date - ISO8601 format e.g. `2021-01-01T00:00:00`
  * Flyby date - ISO8601 format e.g. `2021-01-01T00:00:00`
  * Orbit insertion - ISO8601 format e.g. `2021-01-01T00:00:00`
  * Enter atmosphere - ISO8601 format e.g. `2021-01-01T00:00:00`
  * Landing date - ISO8601 format e.g. `2021-01-01T00:00:00`
  * Space Agency - of the form `earth-nasa`
  * Objective - planet name (lowercase) e.g. `mars`
  * In-play score - the in-play score of this match e.g. `1-0`
  * Final score - the final score of the match e.g. `1-1`
  * Successfully reached orbit - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Successfully left orbit - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Successful flyby - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Successful orbiter - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Successful atmosphere probe - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Successful lander - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Successful rover - e.g `TRUE`, `FALSE`, or leave blank if not relevant
  * Link - a URL of the mission website
  * Report - text of the match report
  * Reporter - name of the reporter(s) with optional HTML links
  * Notes - any further notes

