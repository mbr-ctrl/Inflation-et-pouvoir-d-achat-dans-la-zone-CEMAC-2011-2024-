library(tidyverse)
library(lubridate)
library(plotly)
library(kableExtra)
inflation_df <- readxl::read_xlsx("Inflation-consumer-prices-data-world-bank.xlsx")
glimpse(inflation_df)
summary(inflation_df)
cemac_countries <- c("Cameroon", "Gabon", "Congo, Rep.", 
                     "Chad", "Central African Republic", 
                     "Equatorial Guinea")
inflation_cemac <- inflation_df %>%
  filter(`Country Name` %in% cemac_countries)
inflation_cemac <- inflation_cemac %>%
  mutate(year = year(ymd(Date))) %>%
  select(-Date)
colnames(inflation_cemac)
inflation_cemac <- inflation_cemac %>%
  drop_na(`Inflation, consumer prices (annual %)`)
unique(inflation_cemac$`Country Name`)
inflation_cemac %>%
  group_by(`Country Name`) %>%
  summarise(
    debut = min(year, na.rm = TRUE),
    fin = max(year, na.rm = TRUE),
    nb_annees = n()
  )
inflation_cemac <- inflation_cemac %>%
  filter(year >= 2011)
inflation_cemac$`Inflation, consumer prices (annual %)` <- as.numeric(inflation_cemac$`Inflation, consumer prices (annual %)`)
class(inflation_cemac$`Inflation, consumer prices (annual %)`)
inflation_stats <- inflation_cemac %>%
  group_by(`Country Name`) %>%
  summarise(
    Moyenne = mean(`Inflation, consumer prices (annual %)`, na.rm = TRUE),
    Médiane = median(`Inflation, consumer prices (annual %)`, na.rm = TRUE),
    Minimum = min(`Inflation, consumer prices (annual %)`, na.rm = TRUE),
    Maximum = max(`Inflation, consumer prices (annual %)`, na.rm = TRUE)
  )

kable(inflation_stats, caption = "Statistiques descriptives de l'inflation (2011–2024)") %>%
  kable_styling(full_width = F, bootstrap_options = c("striped", "hover"))

p1 <- ggplot(inflation_cemac, aes(x = year, y = `Inflation, consumer prices (annual %)`, color = `Country Name`)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "Évolution du taux d’inflation dans la CEMAC (2011–2024)",
    subtitle = "Source : Banque mondiale – Inflation, consumer prices (annual %)",
    x = "Année", y = "Inflation annuelle (%)",
    color = "Country Name"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

ggplotly(p1)

p2 <- inflation_stats %>%
  ggplot(aes(x = reorder(`Country Name`, -Moyenne), y = Moyenne, fill = `Country Name`)) +
  geom_col() +
  geom_text(aes(label = round(Moyenne, 1)), vjust = -0.5) +
  labs(title = "Inflation moyenne (2011–2024)", x = "", y = "%") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

ggplotly(p2)
