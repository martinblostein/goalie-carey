library(data.table)
library(lubridate)
library(ggplot2)

games <- readRDS("data_storage/raw_tables.rds")

setnames(games, c("V1", "V2"), c("Home", "TeamDEC"))

games <- games[Rk != "Rk"]
games[, `:=`(Rk = NULL, Age = NULL, Tm = NULL)]
games[, Date := ymd(Date)]
games[DEC == "" | DEC == "\\", DEC := "N"]
games[DEC == "O", DEC := "OTL"]
games[, `:=`(Date = ymd(Date),
             G       = NULL,
             Home    = (Home != "@"),
             TeamDEC = as.factor(TeamDEC),
             DEC     = as.factor(DEC),
             GA      = as.numeric(GA),
             SA      = as.numeric(SA),
             SV      = as.numeric(SV),
             `SV%`   = as.numeric(`SV%`),
             SO      = as.numeric(SO),
             PIM     = as.numeric(PIM))]

games[, Day := lubridate::wday(Date, label = TRUE)]

games[, `:=`(W = DEC == "W",
             L = DEC == "L",
             OTL = DEC == "OTL")]
games[, GwD := W | L | OTL]

games[, isSat := Day == "Sat"]

saveRDS(games, "data_storage/games.rds")

gamesByDay <- games[, .(G = .N, GwD = nrow(.SD[DEC != "N"]), W = sum(W), L = sum(L), OTL = sum(OTL),
                        SV = sum(SV), SA = sum(SA), `SV%` = sum(SV)/sum(SA)),
                    by = .(Day,playoffs)]

gamesByDay[, `:=`(`W%` = sum(W)/GwD,
                  `L%` = sum(L)/GwD,
                  `OTL%` = sum(OTL)/GwD),
           by = .(Day,playoffs)]

gamesBySat <- games[, .(G = .N, GwD = nrow(.SD[DEC != "N"]), W = sum(W), L = sum(L), OTL = sum(OTL),
                        SV = sum(SV), SA = sum(SA), `SV%` = sum(SV)/sum(SA)),
                    by = .(isSat,playoffs)]

gamesBySat[, `:=`(`W%` = sum(W)/GwD,
                  `L%` = sum(L)/GwD,
                  `OTL%` = sum(OTL)/GwD),
           by = .(isSat,playoffs)]

saveRDS(gamesByDay, "data_storage/gamesByDay.rds")
saveRDS(gamesBySat, "data_storage/gamesBySat.rds")

meltedGames <- melt(gamesByDay, id.vars = c("Day", "playoffs"), measure.vars = list(c("W", "L", "OTL"), c("W%", "L%", "OTL%")),
                    variable = "Result", value = c("Count","%"))
levels(meltedGames$Result) <- c("W", "L", "OTL")

saveRDS(meltedGames, "data_storage/meltedGames.rds")

meltedGamesBySat <- melt(gamesBySat, id.vars = c("isSat", "playoffs"), measure.vars = c("W%", "L%", "OTL%"),
                         variable = "Result", value = "%")
saveRDS(meltedGamesBySat, "data_storage/meltedGamesBySat.rds")
