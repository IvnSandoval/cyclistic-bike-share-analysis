# Cyclistic Bike-Share Analysis

## Project Overview

This project analyzes 12 months of Divvy bike-share trip data to identify differences in riding behavior between casual riders and annual members.

The goal of the analysis is to provide data-driven recommendations that could help Cyclistic encourage casual riders to become annual members.

## Business Task

How do annual members and casual riders use Cyclistic bikes differently?

By identifying differences in riding patterns, Cyclistic can develop marketing strategies targeted toward converting casual riders into annual members.

## Tools Used

- PostgreSQL / DBeaver — data cleaning, transformation, and analysis
- Python — data inspection and validation
- Tableau — data visualization and dashboard creation
- Google Docs — final case study report

## Analysis Process

The project followed the Google Data Analytics process:

**Ask → Prepare → Process → Analyze → Share → Act**

## Data Source

The analysis used 12 months of historical Divvy bike-share trip data provided by the City of Chicago.

Each monthly dataset contained individual ride records with information such as:

- Ride ID
- Bike type
- Start and end timestamps
- Start and end station information
- Geographic coordinates
- Rider type: member or casual

Because the original datasets contain a very large number of records, the raw monthly CSV files are not included in this repository. Smaller summary datasets used for analysis and visualization are included instead.

## Data Preparation and Cleaning

The monthly datasets were inspected and cleaned before analysis.

The main preparation steps included:

- Reviewing table structure and column consistency
- Checking row counts and date ranges
- Identifying missing values
- Checking for duplicate ride IDs
- Investigating invalid or negative ride durations
- Standardizing fields and categories
- Combining the monthly datasets into one clean dataset
- Creating calculated variables such as ride duration
- Performing quality checks before analysis
