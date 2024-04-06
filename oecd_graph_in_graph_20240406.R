library(tidyverse)

#https://stats.oecd.org/index.aspx?lang=en
df_base <- read_csv("HEALTH_REAC_24022024233005711.csv") %>%
  mutate(var_measure = paste(Variable, Measure, sep = " ")) %>%
  select(var_measure, Country, Year, Value) %>%
  filter(!is.na(Value)) %>%
  distinct(.keep_all = TRUE)

df_jpn <- df_base %>%
  filter(Country == "Japan")
#日本が各指標で提出している最新年の抽出
df_year_jpn <- df_jpn %>%
  group_by(var_measure) %>%
  summarise(latest_year = max(Year), .groups = "drop")
table(df_year_jpn$latest_year)
#日本が各指標で提出している最新年は2020が126件、2021年が37件、2022年が12件。
#他国の提出状況もあるので、2020年データで他国と比較する。
latest_year <- 2020
#2020年にデータ提出している国数と、日本の順位の抽出
df_latest_year <- filter(.data = df_base, Year == latest_year)
vec_variable <- distinct(.data = df_latest_year, var_measure)
vec_variable <- vec_variable$var_measure
df_rank <- map(vec_variable, ~{
  df_work <- df_latest_year %>%
    filter(var_measure == .x) %>%
    arrange(desc(Value))
  vec_n <- nrow(df_work)
  vec_rank <- which(df_work$Country == "Japan")
  dplyr::tibble(variable = .x,
                n_countries = vec_n,
                jpn_rank = vec_rank)
}) |> list_rbind() %>%
  arrange(desc(n_countries)) %>%
  arrange(jpn_rank) %>%
  mutate(file_name = str_replace_all(variable, fixed(" "), "_")) %>%
  mutate(file_name = str_replace_all(file_name, fixed("/"), "devide_")) %>%
  mutate(file_name = str_c(file_name, latest_year,".png"),
         folder_file_name = str_c("./two_axis_graph/", file_name),
         graph_title = paste(variable, latest_year, sep = ", "))

#連続グラフ保存
map(1:nrow(df_rank), ~{
  df_filter <- df_latest_year %>%
    filter(var_measure == df_rank$variable[.x]) %>%
    mutate(jpn = if_else(Country == "Japan", 1, 0),
           graph_color = if_else(Country == "Japan", "red", "blue")) %>%
    arrange(Value) %>%
    arrange(jpn) %>%
    mutate(Country = factor(Country, levels = unique(Country)))
  df_jpn_filter <- df_jpn %>%
    filter(var_measure == df_rank$variable[.x]) %>%
    arrange(Year)
  #折れ線グラフの均等化
  mapped_years <- seq(from = 1, to = nrow(df_filter),
                      length.out = nrow(df_jpn_filter))
  df_jpn_filter <- df_jpn_filter %>%
    mutate(MappedYear = mapped_years)
  
  #ylim()の上限設定
  max_value <- max(max(df_filter$Value), max(df_jpn_filter$Value))
  
  g_5 <- ggplot(data = df_filter, aes(x = Country, y = Value)) +
    geom_bar(stat = "identity", aes(fill = graph_color), show.legend = FALSE) +
    scale_fill_manual(values = c("red" = "red", "blue" = "blue")) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = df_rank$graph_title[.x]) +
    ylim(c(0, max_value)) +
    geom_line(data = df_jpn_filter,
              aes(x = MappedYear, y = Value), colour = "red",
              linewidth = 1)
  ggsave(df_rank$folder_file_name[.x], plot = g_5,
         width = 4093, height = 2894, units = c("px"))
})

# 
# df_filter <- df_latest_year %>%
#   filter(var_measure == df_rank$variable[1]) %>%
#   mutate(jpn = if_else(Country == "Japan", 1, 0),
#          graph_color = if_else(Country == "Japan", "red", "blue")) %>%
#   arrange(Value) %>%
#   arrange(jpn) %>%
#   mutate(Country = factor(Country, levels = unique(Country)))
# df_jpn_filter <- df_jpn %>%
#   filter(var_measure == df_rank$variable[1]) %>%
#   arrange(Year)
# #折れ線グラフの均等化
# mapped_years <- seq(from = 1, to = nrow(df_filter),
#                     length.out = nrow(df_jpn_filter))
# df_jpn_filter <- df_jpn_filter %>%
#   mutate(MappedYear = mapped_years)
# 
# #ylim()の上限設定
# max_value <- max(max(df_filter$Value), max(df_jpn_filter$Value))
# 
# g_5 <- ggplot(data = df_filter, aes(x = Country, y = Value)) +
#   geom_bar(stat = "identity", aes(fill = graph_color), show.legend = FALSE) +
#   scale_fill_manual(values = c("red" = "red", "blue" = "blue")) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   labs(title = unique(df_filter$var_measure)) +
#   ylim(c(0, max_value)) +
#   geom_line(data = df_jpn_filter,
#             aes(x = MappedYear, y = Value), colour = "red",
#             linewidth = 1)
# ggsave(df_rank$folder_file_name[1], plot = g_5,
#        width = 4093, height = 2894, units = c("px"))
