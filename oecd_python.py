import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# CSVファイルからデータを読み込む
df_base = pd.read_csv('df_test.csv')

# データのフィルタリングと加工
last_year = 2020
df_jpn = df_base[(df_base['Country'] == 'Japan') & (df_base['Year'] <= last_year)]
df_filter = df_base[df_base['Year'] == last_year].dropna(subset=['Value'])

# 日本以外をValueで昇順にソートし、日本を最後に追加
df_filter_non_japan_asc = df_filter[df_filter['Country'] != 'Japan'].sort_values(by='Value', ascending=True)
df_japan = df_filter[df_filter['Country'] == 'Japan']
df_filter_sorted_final_asc = pd.concat([df_filter_non_japan_asc, df_japan])

# 国名をカテゴリとして扱い、日本を最後にする
df_filter_sorted_final_asc['Country'] = pd.Categorical(df_filter_sorted_final_asc['Country'], categories=df_filter_sorted_final_asc['Country'].unique())

# 折れ線グラフのためのx軸位置を計算
years = df_jpn['Year'].unique()
line_x_positions = np.linspace(0, len(df_filter_sorted_final_asc) - 1, len(years))

# グラフ作成
plt.figure(figsize=(12, 8))

# 棒グラフ
colors_asc = ['blue' if country != 'Japan' else 'red' for country in df_filter_sorted_final_asc['Country']]
plt.bar(df_filter_sorted_final_asc['Country'], df_filter_sorted_final_asc['Value'], color=colors_asc)

# 折れ線グラフ
plt.plot(line_x_positions, df_jpn['Value'], color='red', marker='o', markersize=5, linestyle='-', linewidth=2)

# x軸の調整
plt.xticks(range(len(df_filter_sorted_final_asc)), df_filter_sorted_final_asc['Country'], rotation=45, ha='right')

# グラフタイトル
plt.title("Values in Ascending Order with Japan's Yearly Data")

# x軸ラベル（国名）
plt.xlabel("Country")

# x軸の上部に年号を追加
ax2 = plt.gca().twiny()  # 二つ目のx軸を追加
ax2.set_xlim(plt.gca().get_xlim())  # 主軸と同じx軸の範囲を設定
ax2.set_xticks(line_x_positions)  # 折れ線グラフのx軸位置を設定
ax2.set_xticklabels(years)  # 年をラベルとして設定
ax2.set_xlabel("Year (for Japan's line graph)")  # x軸のラベルを設定

plt.tight_layout()
plt.show()
