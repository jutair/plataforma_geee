#Bibliotecas necessárias
library(shiny)
library(googlesheets4)
library(data.table)
library(ggplot2)
library(lubridate)
library(googleAuthR)
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
####################Aquisição de dados###############################################
planilha<- read_sheet("https://docs.google.com/spreadsheets/d/11P9UTyCBhKfqkWL37UmZTSi8onVnaGCYW7rZaRlD6iw/edit#gid=0")
####################Processamento e extração########################################
data<- c(planilha$data) #Extrai os dados da coluna referente a data
data<- c(as.character.Date(data, "%d/%m/%Y"))#Converte os dados para formato Data/Hora
hora<- c(planilha$hora) #Extrai os dados da coluna referente a hora
hora<- c(as.character.Date(hora, format ="%H:%M")) #Converte os dados para formato Data/Hora
assign("kwh", 0.0002777778) #Fator de de conversão de KW/s para KW/h
assign("vkwh", 0.92) #Valor do KW/h para o estado SP, consumidor residencial
circuito<- c(planilha$circuito) #Extrai os dados da coluna referente ao circuito (onde o sensor foi instalado)
mean_corr<- c(planilha$mean_corr) #Extrai os dados da coluna referente a media da corrente obtida pelos sensores
mean_corr<- c(as.numeric(mean_corr)) #Converte os dados para do tipo numérico
mean_tensao<- c(planilha$mean_tensao) #Extrai os dados da coluna referente a media da tensao obtida pelos sensores
mean_tensao <-c(as.numeric(as.character(mean_tensao))) #Converte os dados para numero
sum_potencia<- c(planilha$sum_potencia) #Extrai os dados da coluna referente a potencia consumida no intervalo do tempo (a cada 10 minutos)
sum_potencia<- c(as.numeric(sum_potencia))*kwh#Converte os dados para do tipo numérico e KW/s para KW/h
dataset<- data.frame(data, hora, circuito,mean_corr, mean_tensao, sum_potencia) #Cria o dataframe para o servidor
dataset_c1 <- dataset[dataset$circuito == "circuito01",]#Extrai dados do circuito 1
dataset_c2 <-dataset[dataset$circuito =="circuito02",]#Extrai dados do circuito 2
cons_c1 <-sum(dataset_c1$sum_potencia, na.rm = TRUE) #Soma o total de Watts comsumido do circuito 1/Elimina os valores não numéricos
cons_c2 <-sum(dataset_c2$sum_potencia, na.rm = TRUE)#Soma o total de Watts comsumido do circuito 2/Elimina os valores não numéricos
t_consumo <-sum(dataset$sum_potencia, na.rm = TRUE)#Soma total do consumo do consumo de todos os circuitos
mean_conc1 <-mean(dataset_c1$sum_potencia, na.rm = TRUE)#Tira a média do consumo do circuito 1/Elimina os valores não numéricos
mean_conc2 <-mean(dataset_c2$sum_potencia, na.rm = TRUE)#Tira a média do consumo do circuito 2/Elimina os valores não numéricos
lisreg_periodo <-tail(dataset, 144)#Seleciona os registros das últimas 24 horas
mean_consumo <-mean(dataset$sum_potencia) #Tira a média do consumo/Elimina os valores não numéricos
max_cons_c1 <-max(dataset_c1$sum_potencia, na.rm = TRUE)#Retorna o valor máximo do consumo do circuito 1/Elimina os valores não numéricos
max_cons_c2 <-max(dataset_c2$sum_potencia, na.rm = TRUE)#Retorna o valor máximo do consumo do circuito 2/Elimina os valores não numéricos
min_cons_c1 <-min(dataset_c1$sum_potencia, na.rm = TRUE) #Retorna o valor minimo do consumo do circuito 1/Elimina os valores não numéricos
min_cons_c2 <-min(dataset_c2$sum_potencia, na.rm = TRUE)#Retorna o valor minimo do consumo do circuito 2/Elimina os valores não numéricos
lisreg_c1 <-tail(dataset_c1) #Mostra os últimos registros do circuito 1
lisreg_c2 <-tail(dataset_c2) #Mostra os últimos registros do circuito 1
ser_max_c1 <-max(dataset_c1$sum_potencia, na.rm = TRUE)#Filtra a linha do consumo máximo para o circuito 1/Elimina os valores não numéricos
lisreg<- tail(dataset, 20) #Mostra os últimos registros enviados
lisreg_c1 <-tail(dataset_c1) #Mostra os últimos registros do circuito 1
lisreg_c2 <-tail(dataset_c2) #Mostra os últimos registros do circuito 1
fatura_h <- t_consumo*vkwh #Calcula o atual valor da fatura

#############################Comandos importantes para limpeza extração dos dados######################################
#is.na(my_df) #Retorna se valores NA no dataset
#colSums(is.na(my_df)) #Retorna a coluna que possui valor NA
#colSums(is.na(dataset)) # Retorna o número das colunas que possuem valores NA
#which(colSums(is.na(dataset))>0) # Retorna o nome e núemro da coluna que possui valor NA
#colSums(is.na(dataset)) > 0 # Retorna verdadeiro e falso para colunas com valor NA


#processar o o lisreg para as tabelas
lisregt_periodo <- data.frame(data, hora, circuito, mean_corr, mean_tensao, sum_potencia*3600)
lisregt_periodo<- rename(lisregt_periodo,c("Data" = "data", "Hora" ="hora", "Circuito" = "circuito", "Corrente Média"= "mean_corr", "Tensão Média"="mean_tensao", "KW"= "sum_potencia...3600"))
lisregt_periodo<- tail(lisregt_periodo, 10)
server <- function(input, output, session) { #Função mestre de entrada, saida e sessão do servidor
  
#Filto de reatividade para pesquisa

  
#Saida de dados extraídos do banco de dados 
  
   output$t_consumo <- renderText({ 
    "CONSUMO TOTAL EM KW:" 
  })
  output$consumo <- renderPrint({ 
    t_consumo
  })
  
  output$t_tarifa <- renderText({ 
    "VALOR DO KW/s RESIDENCIAL:" 
  })
  
  output$v_tarifa <- renderPrint({ 
    kwh
  })
  
  output$t_fatura <- renderText({ 
    "VALOR DA FATURA:" 
  })
  
  output$v_fatura <- renderPrint({ 
    fatura_h
  })
  
  
  output$p_consumoc <- renderText({ 
    "PERCENTUAL DO CONSUMO POR CIRCUITO:" 
  })
  
  output$tex_ln <- renderText({ 
    "GRÁFICO DO CONSUMO NAS ÚLTIMAS 24 HORAS" 
  })
  
  
  ######Gráfico de pizza da soma dos consumos########
  
  output$piecons <-renderPlotly({
    
    df_piecons <- data.frame(
      circuito= c("Circuito 01", "Circuito 02"),
      consumo= c(cons_c1, cons_c2)
    )
    
    fig<- plot_ly(df_piecons, labels = ~circuito, values = ~consumo, type = 'pie')
    fig <- fig %>% layout(title = '',
                          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
    fig
    
  })
  #####################################################
  
  #====>FunçFunçaõ para gerar o gráfico de linha<=====####
  output$grapot <- renderPlot({
    gr_c1 <- lisreg_periodo[lisreg_periodo$circuito == "circuito01",]#Extrai dados do circuito 1 das últimas 24 horas
    gr_c2 <-lisreg_periodo[lisreg_periodo$circuito =="circuito02",]#Extrai dados do circuito 2 das últimas 24 horas
    h_pc <-gr_c1[,c("hora")] 
    #lista a coluna potencia do circuito 1
    p_c1 <-gr_c1[,c("sum_potencia")] 
    #lista a coluna hora do circuito 1
    h_pc <-gr_c1[,c("hora")] 
    #lista a coluna potencia do circuito 2
    p_c2 <-gr_c2[,c("sum_potencia")]
    #Une a hora e as potencias dos circuitos 1 e circuito 2
    df_grapot<- bind_cols(h_pc,p_c1,p_c2)
    #renomeia as colunas
    df_grapot<- rename(df_grapot,c("Hora" = "...1", "Circuito01" = "...2","Circuito02" = "...3" ))
    

  })
  
  
  ###############################Função para plotar o gráfico de linha##########################
  ###############################Consumo das últimas 24 horas###################################
  output$line_con <-renderPlotly({
    
    gr_c1 <- lisreg_periodo[lisreg_periodo$circuito == "circuito01",]#Extrai dados do circuito 1 das últimas 24 horas
    gr_c2 <-lisreg_periodo[lisreg_periodo$circuito =="circuito02",]#Extrai dados do circuito 2 das últimas 24 horas
    h_pc <-gr_c1[,c("hora")] 
    #lista a coluna potencia do circuito 1
    p_c1 <-gr_c1[,c("sum_potencia")] 
    #lista a coluna hora do circuito 1
    h_pc <-gr_c1[,c("hora")] 
    #lista a coluna potencia do circuito 2
    p_c2 <-gr_c2[,c("sum_potencia")]
    #Une a hora e as potencias dos circuitos 1 e circuito 2
    df_grapot<- bind_cols(h_pc,p_c1,p_c2)
    #renomeia as colunas
    df_grapot<- rename(df_grapot,c("Hora" = "...1", "Circuito01" = "...2","Circuito02" = "...3" ))
 
    lisreg_periodo<-rename(lisreg_periodo,c("Hora" ="hora", "KW" = "sum_potencia"))
    lisreg_periodo$circuito[lisreg_periodo$circuito == "circuito01"]<- "Circuito 01" #Altera os valores da linha por condição
    lisreg_periodo$circuito[lisreg_periodo$circuito == "circuito02"]<- "Circuito 02" #Altera os valores da linha por condição
    fig <- plot_ly(lisreg_periodo, x = ~Hora, y = ~KW, color = ~circuito) 
    fig <- fig %>% add_lines()
    
    fig
    
    
  })
  
  #################################################
  output$u_reg <- renderText({ 
    "10 ÚLTIMOS REGISTROS MEDIDOS PELOS SENORES:" 
  })
  output$l_reg <- renderTable({ 
    lisregt_periodo
  })
 

  }
