class Menu {
  // Fondo
  PImage background;
  float backPosX, backPosY;

  // Booleanos y objeto para los fades
  boolean terminoFadeIn, empezarFadeOut;
  Cortina cortina;

  boolean musica;

  // Constructor
  Menu() {
    background = loadImage("data/imagenes/menu/background.png");
    musica = true;
  }

  void dibujarFondo() {
    // Se dibuja el fondo y se lo mueve para que, al llegar a cierta posición, se recinicie y se mantenga el bucle
    imageMode(CORNER);
    image(background, backPosX, backPosY, 3000, 3000);
    backPosX--;
    backPosY--;

    if (backPosX <= -1500 && backPosY <= -1500) 
      backPosX=backPosY=0;
  }
}

class MenuStart extends Menu {
  // Easing para mover el logo y el dialogo para comenzar a jugar
  Ease easeLogo, easeEmpezar;


  // Imagenes propias del Start Menu
  PImage logo, textoGolpeeComenzar, formaGolpeeComenzar;

  // Variables para controlar el texto("Golpea para comenzar), su opacidad y fondo.
  int textoAlpha;
  boolean textoAlphaDireccion;
  float formaGolpeePosX, textoGolpeePosX, logoPosY;

  // Se pasa por valor el objeto del leaderboard
  Leaderboard leaderboard;

  MenuStart(Leaderboard leaderboard) { 

    //this.leaderboard = leaderboard;

    //leaderboard = new Leaderboard();
    textoAlpha = 0;
    textoAlphaDireccion = true;

    logoPosY =- 200;
    formaGolpeePosX = width;

    logo = loadImage("data/imagenes/menu/logo.png");
    formaGolpeeComenzar = loadImage("data/imagenes/menu/formaGolpeeComenzar.png");
    textoGolpeeComenzar = loadImage("data/imagenes/menu/textoGolpeeComenzar.png");

    easeLogo = new Ease();
    easeEmpezar = new Ease();

    terminoFadeIn = true;
    empezarFadeOut = true;

    cortina = new Cortina(0);
  }

  // Función para dibujar el menú
  void dibujar() {

    if (musica) {
      musicaMenuPrincipal.loop();
      musica = false;
    }
    // Se dibuja el fondo y se lo mueve para que, al llegar a cierta posición, se recinicie y se mantenga el bucle
    dibujarFondo();

    // Se dibuja el logo
    imageMode(CENTER);
    image(logo, width/2, logoPosY, 964, 620);

    //Se desplaza el logo
    easeLogo.inicializar(width/2, logoPosY, 964, 620);
    easeLogo.target(width/2, 300);
    easeLogo.easePos(0.05);

    logoPosY = easeLogo.posY;

    // Se dibuja el fondo del dialogo de "Golpea para comenzar"
    imageMode(CORNER);
    image(formaGolpeeComenzar, formaGolpeePosX, height-170, 612, 78);

    // Se desplaza el logo
    easeEmpezar.inicializar(formaGolpeePosX, height-170, 612, 78);
    easeEmpezar.target(width-612, height-170);
    easeEmpezar.easePos(0.09);

    formaGolpeePosX = easeEmpezar.posX;

    // Cuando el fondo del dialogo llega a su posición, se dibuja el texto de éste.
    if (easeEmpezar.listo == false) {
      pushStyle();

      // Se utiliza tint para hacerlo intermitente
      tint(360, textoAlpha);
      image(textoGolpeeComenzar, width-510, height-150, 431, 36);

      if (textoAlphaDireccion)
        textoAlpha += 5;
      else 
      textoAlpha -= 5;

      if (textoAlpha >= 255 || textoAlpha <= 0)
        textoAlphaDireccion  = !textoAlphaDireccion;

      popStyle();
    }

    // Se dibuja el leaderboard  
    if (leaderboard != null)
      leaderboard.dibujar(250, height-170, 24);

    // Se dibuja la cortina para el fadeout
    cortina.dibujar();
    cortina.fadeOut("cinematicaCallejon");

    // Si se presiona una tecla, oscurecer y pasar a la cinemática 1.
    if (golpe() && empezarFadeOut && easeEmpezar.listo == false) {
      select.trigger();
      cortina.activar("out");
      empezarFadeOut = false;
    }
  }
}

class MenuSeleccion extends Menu {
  // Variable para almacenar el nombre del personaje que luego se construirá
  String personaje;

  // Imagenes de la selección.
  PImage seleccion, zarpazo, baast;

  // Variables para controlar el tiempo 
  int tiempoInicial;
  boolean millis;
  String actual;

  // Variables para el feedback
  SistemaParticulas sp;
  int bolsaY;
  int bolsaVerdeX;
  int bolsaAzulX;

  MenuSeleccion() { 
    // Selección
    seleccion = loadImage("data/imagenes/menu/seleccion/seleccion.png");
    zarpazo = loadImage("data/imagenes/menu/seleccion/zarpazo.png");
    baast = loadImage("data/imagenes/menu/seleccion/baast.png");

    millis = true;
    actual = "";

    bolsaY = 547;
    bolsaVerdeX = 1202;
    bolsaAzulX = 152;

    cortina = new Cortina(255);

    terminoFadeIn = false;
    empezarFadeOut = false;
  }

  void dibujar() {
    if (musica) {
      musicaSeleccion.loop();
      musica = false;
    }

    if (!terminoFadeIn) {
      cortina.activar("in");
      cortina.fadeIn();
      if (cortina.listo) terminoFadeIn = true;
    }

    dibujarFondo();

    // Se dibuja el fondo(con el personaje seleccionado)
    if (actual == "")
      image(seleccion, 0, 0, width, height);
    if (actual == "azul") {
      image(zarpazo, 0, 0, width, height);
      fill(360);
      textAlign(CENTER);
      text("FÁCIL", width / 2, 60);
    }
    if (actual == "rojo") {
      image(baast, 0, 0, width, height);
      fill(360);
      textAlign(CENTER);
      text("DIFÍCIL", width / 2, 60);
    }

    // Si se golpea una bolsa(verde o azul) por primera vez, se activa marca un personaje
    if (terminoFadeIn && !empezarFadeOut) {
      if (golpe() && millis) {
        if (colorGolpe() == "azul") {
          select.trigger(); 
          actual = "azul";
          sp = new SistemaParticulas(bolsaAzulX, bolsaY, 20, 3);
        }
        if (colorGolpe() == "rojo") {
          select.trigger(); 
          actual = "rojo";
          sp = new SistemaParticulas(bolsaVerdeX, bolsaY, 20, 3);
        }
        tiempoInicial = millis();
        millis = false;
      }
    }

    // Si no pasaron 5 segundos y más de 350ms se selecciona un personaje 
    if (golpe() && millis() < tiempoInicial + 5000 && millis() > tiempoInicial + 350 && !empezarFadeOut) {
      // Si se golpea dos veces al azul, se selecciona a Zarpazo definitivamente
      if (actual == "azul" && colorGolpe() == "azul" && !millis) {
        select.trigger();
        personaje = "zarpazo";
        empezarFadeOut = true;
        millis = true;
        sp = new SistemaParticulas(bolsaAzulX, bolsaY, 20, 3);
      }

      // Si se golpea dos veces al verde, se selecciona a Baast definitivamente
      if (actual == "rojo" && colorGolpe() == "rojo" && !millis) {
        select.trigger();
        personaje = "baast";
        empezarFadeOut = true;
        millis = true;
        sp = new SistemaParticulas(bolsaVerdeX, bolsaY, 20, 3);
      }

      // Si se golpea el verde después del azul, se  Marca a Baast
      if (actual == "azul" &&  colorGolpe() == "rojo" && !millis) {
        select.trigger();
        millis = true;
        actual = "rojo";
      }
      // Si se golpea el azul después del verde, se marca a Zarpazo
      if (actual == "rojo" &&  colorGolpe() == "azul" && !millis) {
        select.trigger();
        millis = true;
        actual = "azul";
      }
      // Si se golpea algún color que no sea ni rojo ni azul
      if ((actual == "azul" && colorGolpe() != "azul") || (actual == "rojo" && colorGolpe() != "rojo") && !millis) {
        millis = true;
        actual = "";
      }
      // Si no se habia golpeando ni la verde ni la azul y se golpea una de estas
      if (actual == "" && colorGolpe() == "azul" && !millis) {
        select.trigger();
        millis = true;
        actual = "azul";
      }
      if (actual == "" && colorGolpe() == "rojo" && !millis) {
        select.trigger();
        millis = true;
        actual = "rojo";
      }
    }

    // Si pasaron 5 segundos, se reestablece
    if (millis() > tiempoInicial + 5000) {
      millis = true;
      actual = "";
    }

    // Se dibujan las particulas si se golpea una bolsa
    if (sp != null)
      sp.dibujar();

    // Se dibuja el fadeIn y fadeOut
    cortina.dibujar();

    // Si `se seleccionó un personaje, oscurecer la pantalla
    if (empezarFadeOut) {
      cortina.activar("out");
      cortina.fadeOut("tutorial");
    }
  }
}

class MenuTutorial extends Menu {
  // Imagenes para el tutorial.
  PImage tutorial, tutorialImagen;

  // Constructor
  MenuTutorial() {

    tutorial = loadImage("data/imagenes/menu/tutorial.png");
    tutorialImagen = loadImage("data/imagenes/menu/tutorialImagen.png");

    cortina = new Cortina(255);

    terminoFadeIn = false;
    empezarFadeOut = false;
  }

  void dibujar() {
    if (!terminoFadeIn) {
      cortina.activar("in");
      cortina.fadeIn();
      if (cortina.listo) terminoFadeIn = true;
    }

    dibujarFondo();

    image(tutorial, 0, 0, width, height);
    image(tutorialImagen, 0, 0, width, height);

    cortina.dibujar();

    if (golpe() && terminoFadeIn && !empezarFadeOut) {
      musicaSeleccion.pause();
      select.trigger();
      empezarFadeOut = true;
    }

    if (empezarFadeOut) {      
      cortina.activar("out");
      cortina.fadeOut("callejon");
      if (cortina.listo) empezarFadeOut = false;
    }
  }
}


class MenuFin extends Menu {
  PImage imagenFin;
  int contador;
  String puntajeFinal;
  boolean musica;

  MenuFin() {
    if (juego.etapaActual == "gameover")
      imagenFin = loadImage("data/imagenes/menu/gameover.png");
    else if (juego.etapaActual == "victoria")  
      imagenFin = loadImage("data/imagenes/menu/ganaste.png");

    cortina = new Cortina(255);

    terminoFadeIn = false;
    empezarFadeOut = false;

    puntajeFinal = nf(juego.puntajeJugador, 8);
    musica = true;
  }

  void dibujar() {
    if (juego.etapaActual == "gameover" && musica == true) {
      pausarMusica();
      musicaGameOver.loop();
      musica = false;
    }

    cortina.activar("in");
    cortina.fadeIn();
    imageMode(CORNER);
    image(imagenFin, 0, 0, width, height);
    pushStyle();
    fill(360);
    textFont(fuenteNeon);
    textAlign(RIGHT);
    textSize(90);
    text(puntajeFinal, 1030, 736);
    popStyle();
    cortina.dibujar();
    contador++;
    switch (contador) {
    case 10:
      cortina.activar("out");
      break;
    case 6000:
      juego = new Juego();
      break;
    }

    if (golpe() == true) {
      select.trigger();
      cortina.activar("out");
      pausarMusica();
      juego = new Juego();
    }
  }
}



class Leaderboard {
  // Datos
  Table tabla;
  String[] jugadores;
  int[] puntajes;

  // Variables para el campo de texto.
  boolean listo;
  boolean nuevoNombre;
  String nombre;

  // Constructor
  Leaderboard() {
    // Se carga el .csv
    tabla = loadTable("https://github.com/Ianmethyst/zarpazo/raw/master/data/leaderboard.csv", "header");

    // println(tabla.getRowCount() + "Cantidad total de filas"); // Debugging

    // Se settea la columna de puntos a int para poder ordenarla, y se ordena1
    tabla.setColumnType("Puntos", Table.INT);
    tabla.sortReverse("Puntos");

    jugadores = new String[tabla.getRowCount()];
    puntajes = new int[tabla.getRowCount()];

    // Variables para el campo de texto

    nuevoNombre = false;
    listo = true;
    nombre = "";

    // Se llenan los arreglos de puntajes y jugadores para poder dibujarlos

    for (int i = 0; i < tabla.getRowCount(); i++) {
      TableRow row = tabla.getRow(i);
      puntajes[i] = row.getInt("Puntos");
      //println(puntajes[i]);
      jugadores[i] = row.getString("Jugador");
      //println(jugadores[i]);
    }
  }

  // Métodos
  void dibujar(int posX, int posY, int text) {
    textAlign(CENTER);
    textFont(fuenteNeon);
    int texto = text;
    fill(#e7d37a);
    textSize(texto+10);
    text("PUNTAJES ALTOS", posX, posY-25);

    for (int i = 0; i < 5; i++) {
      textSize(texto);
      textAlign(LEFT);
      text((i + 1) + ". " + jugadores[i], posX-130, posY + texto * i);
      text(" - ", posX, posY + texto * i);
      textAlign(RIGHT);
      text(nf(puntajes[i], 6), posX+130, posY + texto * i);
    }
  }

  void agregarPuntaje(Jugador jugador) {
    if (nuevoNombre == true) {
      TableRow newRow = tabla.addRow();
      newRow.setInt("Puntos", jugador.puntos);
      newRow.setString("Nombre", nombre);

      saveTable(tabla, "leaderboard.csv");
    }
  }
}