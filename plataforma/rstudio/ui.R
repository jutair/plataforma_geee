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
  # Tema da página
  theme = shinytheme("flatly"),
  
  # Título da página                
  titlePanel(p("SISTEMA DE MONITORAMENTO DE CONSUMO DE ENERGIA", style="text-align:center" )),
  br(),
  br(),

  #Saida dos dados extraídos da base de dados
  textOutput("t_consumo"),
  verbatimTextOutput("consumo"),
  textOutput("t_mconsumo"),
  verbatimTextOutput("m_consumo"),
  plotlyOutput('line_con'),
  #plotOutput("grapot", click = "plot_click"),  #Chama do servidor o gráfico da linha de história do consumo dos circuitos
  plotlyOutput('piecons'), #Chama do servidor o gráfico de pizza do consumo dos circuitos
  textOutput("u_reg"),
  tableOutput('l_reg'),
  
)