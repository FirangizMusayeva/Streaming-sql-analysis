"""Generates the synthetic datasets used in this project (fixed seed -> reproducible).
All data is artificial. No real company or academy data is used."""
import csv, random
from datetime import date, timedelta

random.seed(42)
GENRES = ["Drama", "Comedy", "Documentary", "Thriller", "Sci-Fi", "Animation", "Romance", "Action"]
COUNTRIES = ["Azerbaijan", "Turkey", "Georgia", "Germany", "USA", "UK", "India", "Brazil"]
PLANS = ["Basic", "Standard", "Premium"]
W1 = ["Silent", "Last", "Hidden", "Broken", "Golden", "Midnight", "Lost", "Distant", "Crimson", "Quiet"]
W2 = ["River", "Signal", "Garden", "Empire", "Voyage", "Harbor", "Echo", "Horizon", "Mirror", "Season"]

# ---------- titles ----------
titles, seen = [], set()
tid = 1
while len(titles) < 400:
    name = f"{random.choice(W1)} {random.choice(W2)}"
    year = random.randint(2005, 2025)
    if (name, year) in seen:
        continue
    seen.add((name, year))
    ttype = random.choices(["Movie", "Series"], [0.6, 0.4])[0]
    duration = random.randint(80, 150) if ttype == "Movie" else random.randint(30, 60)
    country = random.choice(COUNTRIES)
    added = date(2024, 1, 1) + timedelta(days=random.randint(0, 700))
    titles.append([tid, name, ttype, random.choice(GENRES), country, year,
                   random.choice(["PG", "PG-13", "R", "TV-14", "TV-MA"]), duration, added.isoformat()])
    tid += 1

canonical = [t[:] for t in titles]           # clean copy used to generate events

# deliberate data-quality problems (to practise cleaning in SQL)
for t in random.sample(titles, 24):           # messy genre text
    t[3] = random.choice([f" {t[3]}", t[3].upper(), t[3].lower(), f"{t[3]} "])
for t in random.sample(titles, 10):           # missing country
    t[4] = ""
for t in random.sample(titles, 8):            # missing rating
    t[6] = ""
for src in random.sample(canonical, 12):      # duplicate title rows with new ids
    titles.append([tid, src[1].lower(), src[2], src[3], src[4], src[5], src[6], src[7], src[8]])
    tid += 1

with open("data/titles.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["title_id", "title", "type", "genre", "country", "release_year", "rating", "duration_min", "date_added"])
    w.writerows(titles)

# ---------- users ----------
users = []
for uid in range(1, 2001):
    signup = date(2024, 6, 1) + timedelta(days=random.randint(0, 570))
    users.append([uid, signup.isoformat(), random.choice(COUNTRIES),
                  random.choices(PLANS, [0.4, 0.4, 0.2])[0]])
with open("data/users.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["user_id", "signup_date", "country", "plan"])
    w.writerows(users)

# ---------- watch events (2025) ----------
genre_weight = dict(zip(GENRES, [1.4, 1.2, 0.6, 1.1, 0.9, 0.8, 0.7, 1.3]))
weights = [genre_weight[t[3]] for t in canonical]
events, eid = [], 1
start, end = date(2025, 1, 1), date(2025, 12, 31)
for u in users:
    signup = date.fromisoformat(u[1])
    first = max(start, signup)
    if first > end:
        continue
    n = int(random.expovariate(1 / 22)) + 1
    for _ in range(n):
        d = first + timedelta(days=random.randint(0, (end - first).days))
        t = random.choices(canonical, weights)[0]
        dur = t[7]
        watched = random.randint(5, dur)
        completed = 1 if watched >= dur * 0.9 else 0
        events.append([eid, u[0], t[0], d.isoformat(), watched, completed])
        eid += 1
with open("data/watch_events.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["event_id", "user_id", "title_id", "watch_date", "minutes_watched", "completed"])
    w.writerows(events)
print(f"titles={len(titles)} users={len(users)} events={len(events)}")
