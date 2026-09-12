import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import re


# ============================================================
# PAGE CONFIGURATION
# ============================================================

st.set_page_config(
    page_title="Global Seismic Trends",
    page_icon="🌍",
    layout="wide"
)


# ============================================================
# TITLE
# ============================================================

st.title("🌍 Global Seismic Trends")
st.subheader("Data-Driven Earthquake Insights")

st.markdown(
    """
    This dashboard analyzes global earthquake activity using
    magnitude, depth, location, time, tsunami indicators,
    reporting networks and data-quality metrics.
    """
)


# ============================================================
# LOAD DATA
# ============================================================

@st.cache_data
def load_data():

    file_path = "earthquake_final.csv"

    df = pd.read_csv(file_path)

    # Convert date columns
    df["time"] = pd.to_datetime(df["time"], errors="coerce")
    df["updated"] = pd.to_datetime(df["updated"], errors="coerce")

    # Rename depth
    if "depth" in df.columns:
        df["depth_km"] = pd.to_numeric(
            df["depth"],
            errors="coerce"
        )

    # Numeric columns
    numeric_columns = [
        "latitude",
        "longitude",
        "depth_km",
        "mag",
        "nst",
        "gap",
        "dmin",
        "rms",
        "horizontalError",
        "depthError",
        "magError",
        "magNst"
    ]

    for column in numeric_columns:

        if column in df.columns:

            df[column] = pd.to_numeric(
                df[column],
                errors="coerce"
            )

    # --------------------------------------------------------
    # Country extraction using Regex
    # --------------------------------------------------------

    def extract_country(place):

        if pd.isna(place):
            return "Unknown"

        match = re.search(
            r",\s*([^,]+)$",
            str(place)
        )

        if match:
            return match.group(1).strip()

        return "Unknown"

    df["country"] = df["place"].apply(
        extract_country
    )

    # --------------------------------------------------------
    # Derived date columns
    # --------------------------------------------------------

    df["year"] = df["time"].dt.year
    df["month"] = df["time"].dt.month
    df["month_name"] = df["time"].dt.month_name()
    df["day"] = df["time"].dt.day
    df["day_of_week"] = df["time"].dt.day_name()
    df["hour"] = df["time"].dt.hour

    # --------------------------------------------------------
    # Depth category
    # --------------------------------------------------------

    def depth_category(depth):

        if pd.isna(depth):
            return "Unknown"

        if depth < 70:
            return "Shallow"

        elif depth < 300:
            return "Intermediate"

        return "Deep"

    df["depth_category"] = df["depth_km"].apply(
        depth_category
    )

    # --------------------------------------------------------
    # Magnitude category
    # --------------------------------------------------------

    def magnitude_category(magnitude):

        if pd.isna(magnitude):
            return "Unknown"

        if magnitude >= 7.5:
            return "Destructive"

        elif magnitude >= 5:
            return "Strong"

        return "Moderate"

    df["magnitude_category"] = df["mag"].apply(
        magnitude_category
    )

    return df


# Load dataset
df = load_data()


# ============================================================
# SIDEBAR
# ============================================================

st.sidebar.header("🔎 Dashboard Filters")


# Year filter
available_years = sorted(
    df["year"].dropna().unique()
)

selected_years = st.sidebar.multiselect(
    "Select Year",
    available_years,
    default=available_years
)


# Magnitude filter
min_mag = float(
    df["mag"].min()
)

max_mag = float(
    df["mag"].max()
)

selected_mag = st.sidebar.slider(
    "Magnitude Range",
    min_value=min_mag,
    max_value=max_mag,
    value=(min_mag, max_mag)
)


# Depth category
depth_options = [
    "Shallow",
    "Intermediate",
    "Deep"
]

selected_depth = st.sidebar.multiselect(
    "Depth Category",
    depth_options,
    default=depth_options
)


# Status
status_options = sorted(
    df["status"].dropna().unique()
)

selected_status = st.sidebar.multiselect(
    "Status",
    status_options,
    default=status_options
)


# ============================================================
# APPLY FILTERS
# ============================================================

filtered_df = df[
    df["year"].isin(selected_years)
    &
    df["mag"].between(
        selected_mag[0],
        selected_mag[1]
    )
    &
    df["depth_category"].isin(
        selected_depth
    )
    &
    df["status"].isin(
        selected_status
    )
].copy()


# ============================================================
# KPI SECTION
# ============================================================

st.header("📊 Key Performance Indicators")


total_earthquakes = len(filtered_df)

average_magnitude = filtered_df["mag"].mean()

max_magnitude = filtered_df["mag"].max()

average_depth = filtered_df["depth_km"].mean()

high_magnitude_events = len(
    filtered_df[
        filtered_df["mag"] >= 7.5
    ]
)


col1, col2, col3, col4, col5 = st.columns(5)


col1.metric(
    "🌋 Total Earthquakes",
    f"{total_earthquakes:,}"
)

col2.metric(
    "📈 Average Magnitude",
    f"{average_magnitude:.2f}"
)

col3.metric(
    "💥 Maximum Magnitude",
    f"{max_magnitude:.2f}"
)

col4.metric(
    "⬇️ Average Depth",
    f"{average_depth:.2f} km"
)

col5.metric(
    "⚠️ Mag ≥ 7.5",
    f"{high_magnitude_events:,}"
)


# ============================================================
# YEARLY TREND
# ============================================================

st.header("📈 Earthquake Trend by Year")


yearly_data = (
    filtered_df
    .groupby("year")
    .size()
    .reset_index(
        name="earthquake_count"
    )
)


fig_year = px.line(
    yearly_data,
    x="year",
    y="earthquake_count",
    markers=True,
    title="Number of Earthquakes per Year"
)

fig_year.update_xaxes(dtick=1, tickformat="d")




fig_year.update_layout(
    xaxis_title="Year",
    yaxis_title="Earthquake Count"
)

st.plotly_chart(
    fig_year,
    use_container_width=True
)


# ============================================================
# MONTHLY ANALYSIS
# ============================================================

st.header("📅 Monthly Earthquake Activity")


monthly_data = (
    filtered_df
    .groupby("month")
    .size()
    .reset_index(
        name="earthquake_count"
    )
)

monthly_data["month_name"] = (
    pd.to_datetime(
        monthly_data["month"],
        format="%m"
    ).dt.month_name()
)


fig_month = px.bar(
    monthly_data,
    x="month_name",
    y="earthquake_count",
    title="Earthquakes by Month"
)

st.plotly_chart(
    fig_month,
    use_container_width=True
)


# ============================================================
# MAGNITUDE DISTRIBUTION
# ============================================================

st.header("📊 Magnitude Distribution")


fig_mag = px.histogram(
    filtered_df,
    x="mag",
    nbins=40,
    title="Distribution of Earthquake Magnitudes"
)

st.plotly_chart(
    fig_mag,
    use_container_width=True
)


# ============================================================
# DEPTH ANALYSIS
# ============================================================

st.header("🌋 Earthquake Depth Analysis")


depth_counts = (
    filtered_df
    .groupby("depth_category")
    .size()
    .reset_index(
        name="count"
    )
)


fig_depth = px.pie(
    depth_counts,
    names="depth_category",
    values="count",
    title="Earthquakes by Depth Category"
)

st.plotly_chart(
    fig_depth,
    use_container_width=True
)


# ============================================================
# MAGNITUDE CATEGORY
# ============================================================

st.header("💥 Magnitude Category")


magnitude_counts = (
    filtered_df
    .groupby("magnitude_category")
    .size()
    .reset_index(
        name="count"
    )
)


fig_category = px.bar(
    magnitude_counts,
    x="magnitude_category",
    y="count",
    title="Earthquakes by Magnitude Category"
)

st.plotly_chart(
    fig_category,
    use_container_width=True
)


# ============================================================
# GLOBAL EARTHQUAKE MAP
# ============================================================

st.header("🌍 Global Earthquake Map")


map_df = filtered_df.dropna(
    subset=[
        "latitude",
        "longitude"
    ]
).copy()

map_df["mag_size"] = map_df["mag"].abs().clip(lower=0.1)

fig_map = px.scatter_geo(
    map_df,
    lat="latitude",
    lon="longitude",
    color="mag",
    size="mag_size",
    hover_name="place",
    hover_data=[
        "mag",
        "depth_km",
        "country",
        "status"
    ],
    color_discrete_sequence=["red"],

    projection="natural earth",
    title="Global Earthquake Locations"
)

st.plotly_chart(
    fig_map,
    use_container_width=True
)


# ============================================================
# TOP COUNTRIES
# ============================================================

st.header("🌎 Most Active Countries")


country_data = (
    filtered_df[
        filtered_df["country"] != "Unknown"
    ]
    .groupby("country")
    .agg(
        earthquake_count=("id", "count"),
        average_magnitude=("mag", "mean")
    )
    .reset_index()
    .sort_values(
        "earthquake_count",
        ascending=False
    )
    .head(10)
)


country_data[
    "average_magnitude"
] = country_data[
    "average_magnitude"
].round(2)


fig_country = px.bar(
    country_data,
    x="earthquake_count",
    y="country",
    orientation="h",
    title="Top 10 Countries by Earthquake Count"
)

st.plotly_chart(
    fig_country,
    use_container_width=True
)


# ============================================================
# REPORTING NETWORK
# ============================================================

st.header("📡 Reporting Network Analysis")

filtered_df["net"] = filtered_df["net"].str.upper()


network_data = (
    filtered_df
    .groupby("net")
    .size()
    .reset_index(
        name="earthquake_count"
    )
    .sort_values(
        "earthquake_count",
        ascending=False
    )
    .head(10)
)


fig_network = px.bar(
    network_data,
    x="net",
    y="earthquake_count",
    title="Top Reporting Networks"
)

st.plotly_chart(
    fig_network,
    use_container_width=True
)


# ============================================================
# STATUS ANALYSIS
# ============================================================

st.header("🔍 Reviewed vs Automatic")


status_data = (
    filtered_df
    .groupby("status")
    .size()
    .reset_index(
        name="count"
    )
)


fig_status = px.pie(
    status_data,
    names="status",
    values="count",
    title="Earthquake Record Status"
)

st.plotly_chart(
    fig_status,
    use_container_width=True
)


# ============================================================
# TSUNAMI ANALYSIS
# ============================================================

st.header("🌊 Tsunami Analysis")


if "tsunami" in filtered_df.columns:

    tsunami_data = (
        filtered_df
        .groupby("tsunami")
        .size()
        .reset_index(
            name="count"
        )
    )

    tsunami_data["tsunami_status"] = (
        tsunami_data["tsunami"]
        .map({
            0: "No Tsunami",
            1: "Tsunami"
        })
    )

    fig_tsunami = px.bar(
        tsunami_data,
        x="tsunami_status",
        y="count",
        title="Tsunami vs Non-Tsunami Events"
    )

    st.plotly_chart(
        fig_tsunami,
        use_container_width=True
    )

else:

    st.info(
        "Tsunami information is not available "
        "in the supplied CSV."
    )


# ============================================================
# DATA QUALITY
# ============================================================

st.header("📡 Data Quality Analysis")


quality_cols = [
    "rms",
    "gap",
    "nst",
    "magError",
    "depthError"
]

available_quality_cols = [
    col for col in quality_cols
    if col in filtered_df.columns
]


quality_summary = (
    filtered_df[
        available_quality_cols
    ]
    .describe()
    .T
)


st.dataframe(
    quality_summary,
    use_container_width=True
)


# ============================================================
# TOP 10 STRONGEST EARTHQUAKES
# ============================================================

st.header("💥 Top 10 Strongest Earthquakes")


top_10 = (
    filtered_df[
        [
            "id",
            "time",
            "place",
            "country",
            "mag",
            "depth_km"
        ]
    ]
    .sort_values(
        "mag",
        ascending=False
    )
    .head(10)
)


st.dataframe(
    top_10,
    use_container_width=True
)


# ============================================================
# TOP 10 DEEPEST EARTHQUAKES
# ============================================================

st.header("⬇️ Top 10 Deepest Earthquakes")


deepest_10 = (
    filtered_df[
        [
            "id",
            "time",
            "place",
            "country",
            "mag",
            "depth_km"
        ]
    ]
    .sort_values(
        "depth_km",
        ascending=False
    )
    .head(10)
)


st.dataframe(
    deepest_10,
    use_container_width=True
)


# ============================================================
# FOOTER
# ============================================================

st.markdown("---")

st.markdown(
    """
    **Global Seismic Trends: Data-Driven Earthquake Insights**

    Built using Python, Pandas, Regex, SQL and Streamlit.
    """
)