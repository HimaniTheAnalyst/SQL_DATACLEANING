# SQL Data Cleaning Project

## Project Overview

This project focuses on cleaning, standardizing, and preparing real estate sales data from the NashvilleHousing dataset. The goal was to ensure data consistency, remove duplicates, handle missing values, and structure complex fields for analysis.

## Key Objectives

- Standardize date formats for uniformity
- Fill missing property addresses using related records
- Identify and remove duplicate rows
- Split combined address fields into structured components
- Convert categorical flags (Y/N) into readable values (Yes/No)

## Data Cleaning Steps

### 1. Standardizing Date Format

- Converted all date fields to a consistent format
- Ensured date columns store only the required information

### 2. Handling Missing Property Addresses

- Filled missing addresses by matching property IDs with other existing records
- Ensured no null or incomplete addresses remain

### 3. Removing Duplicate Records

- Identified duplicates based on ParcelID and PropertyAddress
- Used self-aliasing techniques for comparison
- Removed redundant entries

### 4. Structuring Address Fields

- Split combined address strings into street, city, and state
- Standardized all address-related fields

### 5. Converting Categorical Flags

- Transformed Y/N fields into Yes/No
- Improved interpretability for reporting

## Project Outcomes

- Dataset fully cleaned and structured
- Missing addresses resolved
- Duplicate records removed
- Address fields broken into granular components
- Categorical flags standardized

## Skills Demonstrated

- Advanced SQL data cleaning and transformation
- Handling missing values and inconsistencies
- Deduplication and quality checks using self-joins and aliases
- String manipulation and parsing in SQL
- Preparing data for analytical workflows
