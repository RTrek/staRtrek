#' Information about episodes in a season (or seasons) of Star Trek
#'
#' Handily get all the episodes in a season (plus extra info) or all the episodes in a given season of Star Trek.
#'
#' @param show a valid identifier for a show
#' @param seasons which season (or seasons) should be included. Overflow will cover all seasons of a show, with no error. Default to \code{"all"}, which shows all seasons.
#' @return a (list of) \code{data.frame}(s) of episodes, season per list item/\code{data.frame}, one episode per row.
#'
#' @author David L. Miller
#' @export
#' @examples
#' # get episodes for season 5 of Deep Space 9
#' episodes("DS9",5)
#' # get episodes for seasons 2 and 3 of the Original Series
#' episodes("TOS", 2:3)
#' @import rvest
#' @importFrom magrittr extract2
#'
episodes <- function(show=c("TOS","TNG","DS9","VOY","ENT"), seasons="all"){

  # do a match arg to select the show
  show <- match.arg(show)

  # how many seasons did each show have?
  valid_seasons <- list("TOS" = 3,
                        "TNG" = 7,
                        "DS9" = 7,
                        "VOY" = 7,
                        "ENT" = 4)

  # deal with the "all" situation
  if(any(seasons=="all")){
    seasons <- 1:valid_seasons[[show]]
  }
  # chop if there are too many/too high season number(s)
  seasons <- seasons[seasons <= valid_seasons[[show]]]
  # throw an error if there are no valid seasons!
  if(length(seasons)==0){
    stop("Sorry, you entered an invalid set of seasons for this show!")
  }

  # make a base URL
  base_url <- paste0(show,"_Season_")

  # function to get a season
  get_season <- function(season){
    # make the URL
    season_url <- paste0(base_url, season)

    # based on code from Andrew MacDonald, pull the table
    paste0("http://en.memory-alpha.org/wiki/", season_url) %>%
      html %>%
      html_nodes("table") %>%
      extract2(1) %>%
      html_table(header = TRUE)
  }

  # apply that function ^_^
  season_table <- lapply(seasons,get_season)

  return(season_table)
}

#' Information about characters in Star Trek
#'
#' Handily get all the information on a single character from memory-alpha.org
#'
#' @param chname a character's name
#' @return a \code{data.frame} giving a character's gender, affiliation, species and rank
#'
#' @author A Andrew M MacDonald
#' @export
#' @examples
#' # get information for Major Kira
#' character_data("Kira_Nerys")
#' # get information for Worf
#' character_data("Worf")
#' @import rvest
#' @importFrom magrittr extract2
#' @importFrom magrittr set_colnames
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom tidyr spread
#'
character_data <- function(chname){
  paste0("http://en.memory-alpha.org/wiki/", chname) %>%
    html %>%
    html_nodes(".wiki-sidebar") %>%
    html_table(header = FALSE) %>%
    extract2(1) %>%
    set_colnames(c("trait", "value")) %>%
    mutate(trait = gsub(":", "", trait)) %>%
    filter(trait %in% c("Gender","Species","Affiliation","Rank")) %>%
    mutate(name = chname) %>%
    spread(trait, value)
}
