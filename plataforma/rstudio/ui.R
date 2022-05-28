#Bibliotecas necessárias
library(shiny)
library(googlesheets4)
library(data.table)
library(shinythemes)
library(ggplot2)
library(lubridate)
library(googledrive)
library(plyr) 
library(dplyr)
library(plotly)
library(shinydashboard)
###########################
#Autenticando o acesso ao google -----------------------------------------------
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "contatojutair@gmail.com")
gs4_auth(token = drive_token())
###########################
#Coletando a base de dados
dataset<- read_sheet("https://docs.google.com/spreadsheets/d/11P9UTyCBhKfqkWL37UmZTSi8onVnaGCYW7rZaRlD6iw/edit?usp=sharing")
###########################


ui <- fluidPage(
  
  # Tema
  theme = shinytheme("flatly"),
  
  # Título                
  titlePanel(p("PLATAFOMRA DE GESTÃO DE ENERGIA", style="text-align:center" )),
  br(),
  br(),
  
  sidebarLayout(
    
    
    sidebarPanel(
      
      verticalLayout( 
    
        textOutput("t_consumo"),
        verbatimTextOutput("consumo"),
        textOutput("t_tarifa"),
        verbatimTextOutput("v_tarifa"),
        textOutput("t_fatura"),
        verbatimTextOutput("v_fatura"),
        textOutput("p_consumoc"),
        plotlyOutput('piecons'), #Chama do servidor o gráfico de pizza do consumo dos circuitos
      
        )
      
      
    ),
  
    
      mainPanel(
        titlePanel(p("GRÁFICOS E TABELAS", style="text-align:center" )),
        tabsetPanel(
          
          
          tabPanel("Hoje", 
                   verbatimTextOutput("tex_ln"),
                    plotlyOutput('line_con'), #Chama o gráfico do
                   ),
                  
          tabPanel("Tabela", 
                   verbatimTextOutput("u_reg"),
                   tableOutput('l_reg'),
                   ),
        ),
        
      )
  )
)
