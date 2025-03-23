import pandas as pd
import json

with open("aeroplane_model.json", "r", encoding="utf-8") as f:
    data = json.load(f)

rows = []
for manufacturer, models in data.items():
    for model, specs in models.items():
        row = {"manufacturer": manufacturer, "model": model, **specs}
        rows.append(row)

df = pd.DataFrame(rows)

df.to_csv("aeroplane_model.csv", index=False)