# app.R
# ================================
# PROPOSITO: Implementa la segunda
#            parte del Ejemplo 1
# ================================
## @knitr DECLARACIONES

library(shiny)
library(miniUI)

datos <- data.frame(
  #               marca.Ms      marca.G
  P.B       =  c(    0.65   ,    0.35     ),  # P(B)
  P.A_B     =  c(    0.30   ,    0.02     ),  # P(A|B)
  row.names =  c("marca.Ms" , "marca.G"   )
)

datos$Prod <- datos$P.B * datos$P.A_B
# La suma de las columnas
sumas <- apply(datos, 2, sum)
# Se agrega el resultado como un renglón al final:
datos["SUMAS", ] <- sumas
datos$Respons <- datos$Prod/datos["SUMAS","Prod"]
  
operateDatos <- function() {
  datos$Prod <<- datos$P.B * datos$P.A_B
  # Se agregan las sumas corregidas como el renglón final:
  datos["SUMAS", ] <<- apply(datos[-3, ], 2, sum)
  datos$Respons <<- datos$Prod/datos["SUMAS","Prod"]
  return(datos)
}

# Define UI for slider demo app ----
ui <- miniPage(
  
  # App title ----
  gadgetTitleBar("Asignación de Correos para Filtar Spam"),
  
  miniTabstripPanel(
    miniTabPanel(
      "Parametros", icon = icon("sliders"),
      miniContentPanel(
        sliderInput("asignaMs.G", "Asignación de correos a Ms:",
                    min = 0, max = 1,
                    value = 0.65, step = 0.05),
        
        wellPanel(
          h4("% de Correos mal detectados"),
          tags$hr(),
          # Input: Correos mal detectados por Ms ----
          sliderInput("P.A_Bm", "Ms:",
                      min = 0, max = 1,
                      value = 0.30, step = 0.01),
          
          # Input: Custom currency format for with basic animation ----
          sliderInput("P.A_Bg", "G:",
                      min = 0, max = 1,
                      value = 0.02, step = 0.01)
        ) #,
      ) # miniContentPanel
    ), # miniTabPanel: Parametros
    miniTabPanel(
      "Datos", icon = icon("table"),
      miniContentPanel(
        tableOutput("valores")
      )
    ), # miniTabPanel: Datos
    miniTabPanel(
      "Resultados", icon = icon("check-square"),
      miniContentPanel(
        tableOutput("datos")
      )
    ), # miniTabPanel: Resultados
    miniTabPanel(
      "Visualiza", icon = icon("chart-pie"),
      miniContentPanel(
        plotOutput("pie")
      )
    )
  )
)


server <- function(input, output, session) {
  output$datos <- renderTable({
    cbind(
      data.frame(Marca=rownames(datos)),
      datos)})
  output$pie <- renderPlot({
    pie(
      datos$Respons[1:2], 
      labels = c("marca.Ms", "marca.G"), 
      col = rainbow(2),
      main = "Responsabilidad por\n mala clasificación de correos")
  })
  

  # Reactive expression to create data frame of all input values ----
  sliderValues <- reactive({
    
    data.frame(
      "Descripción" = c(# "Integer",
               "asignación Ms P(Bm)",
               "asignación G P(Bg)",
               "Mal detectados Ms",
               "Mal detectados G"),
      Valor = as.character(c(# input$integer,
                             input$asignaMs.G,
                             1-input$asignaMs.G,
                             input$P.A_Bm,
                             input$P.A_Bg)),
      stringsAsFactors = FALSE)
  })
  
  # Show the values in an HTML table ----
  output$valores <- renderTable({
    sliderValues()
  })
  
  operaValues <- reactive({
    datos$P.B <<- c(input$asignaMs.G, 1-input$asignaMs.G, NA)
    datos$P.A_B <<- c(input$P.A_Bm, input$P.A_Bg, NA)
    cbind(data.frame(Marca=rownames(datos)), operateDatos())
  })
  
  output$datos <- renderTable({
    operaValues()
  })
  
  output$pie <- renderPlot({
    tt <- operaValues()
    m <- tt$Marca[1:2]
    v <- tt$Respons[1:2]
    lb <- paste(
      m,
      paste0(format(v*100, digits = 1), "%"), 
      sep="\n")
    pie(
      v, 
      labels = lb, 
      col = rainbow(2),
      main = "Responsabilidad por\n mala clasificación de correos")
    
  })
}

## @knitr APLICACION

# Create Shiny app ----
shinyApp(ui, server)
# runGadget(shinyApp(ui, server), viewer = paneViewer())

