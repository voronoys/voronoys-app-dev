tab_files <- list.files(path = "tabs/ui/candidatos", full.names = T)
suppressMessages(lapply(tab_files, source))

candidato <- tabPanel(title = "Candidatos", 
                      value = "candidatos",
                      hr(),
                      tabsetPanel(
                        perfil,
                        perfil_eleitorado
                      )
)