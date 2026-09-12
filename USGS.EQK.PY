import requests
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import sqlalchemy as sqlalchemy
from sqlalchemy import create_engine
import streamlit as st


eqk_info = pd.read_csv("C:/Users/V MANINDRA KUMAR/Desktop/US EARTHQUAKES.csv")

df = pd.DataFrame(eqk_info)

print(eqk_info.head(9593))


df.info()

df.describe()

print(df.columns)

print(df.isnull().sum())


df['place'] = df['place'].str.upper()

df['locationSource'] = df['locationSource'].str.upper()

df['magSource'] = df['magSource'].str.upper()

print(df.columns.tolist())

print(eqk_info.head(9593))

# Convert Date columns

df["time"] = pd.to_datetime(df["time"], errors="coerce")
df["updated"] = pd.to_datetime(df["updated"], errors="coerce")

# Convert Numeric Columns

numeric_cols = [
    "latitude","longitude","depth","mag",
    "nst","gap","dmin","rms",
    "horizontalError","depthError",
    "magError","magNst"
]

for col in numeric_cols:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce")


# Fill Missing Numeric Values

for col in numeric_cols:
    if col in df.columns:
        df[col] = df[col].fillna(df[col].median())

# Fill Missing Categorical Values

categorical_cols = [
    "magType","net","place","type",
    "status","locationSource","magSource"
]

for col in categorical_cols:
    if col in df.columns:
        df[col] = df[col].fillna("Unknown")

# Extract Country/Location

df["country"] = df["place"].str.extract(r",\s*(.*)")
df["country"] = df["country"].fillna(df["place"])

# Create Date Features

df["Year"] = df["time"].dt.year

df["Month"] = df["time"].dt.month

df["Day"] = df["time"].dt.day

df["Hour"] = df["time"].dt.hour

df["Day_Name"] = df["time"].dt.day_name()

# Create Depth Category

def depth_category(depth):
    if depth < 70:
        return "Shallow"
    elif depth < 300:
        return "Intermediate"
    else:
        return "Deep"

df["Depth_Category"] = df["depth"].apply(depth_category)

# Create Magnitude Category

def magnitude_category(mag):
    if mag < 3:
        return "Minor"
    elif mag < 5:
        return "Light"
    elif mag < 6:
        return "Moderate"
    elif mag < 7:
        return "Strong"
    else:
        return "Major"

df["Magnitude_Category"] = df["mag"].apply(magnitude_category)

print(df.info())
print(df.head())

df.to_csv("earthquake_cleaned.csv", index=False)

# Top 10 Strongest Earthquakes

top_mag = df.sort_values(by="mag", ascending=False).head(10)
print(top_mag[["time","place","mag"]])

# Top 10 Deepest Earthquakes

top_depth = df.sort_values(by="depth", ascending=False).head(10)
print(top_depth[["time","place","depth"]])

# Earthquakes by Country

print(df["country"].value_counts().head(10))

# Magnitude Distribution

plt.figure(figsize=(8,5))
plt.hist(df["mag"], bins=20)
plt.title("Magnitude Distribution")
plt.xlabel("Magnitude")
plt.ylabel("Count")
plt.show()

# Depth Distribution

plt.figure(figsize=(8,5))
plt.hist(df["depth"], bins=20)
plt.title("Depth Distribution")
plt.xlabel("Depth")
plt.ylabel("Count")
plt.show()

# Scatter Plot (Depth vs Magnitude)

plt.figure(figsize=(8,5))
plt.scatter(df["depth"], df["mag"])
plt.xlabel("Depth")
plt.ylabel("Magnitude")
plt.title("Depth vs Magnitude")
plt.show()

# Box Plot for Magnitude

plt.figure(figsize=(6,4))
plt.boxplot(df["mag"].dropna())
plt.title("Magnitude Boxplot")
plt.show()

# Correlation Matrix

numeric_df = df.select_dtypes(include=["number"])
print(numeric_df.corr())

df.to_csv("earthquake_final.csv", index=False)








