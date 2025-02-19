class Nivel {
  // Objeto para el sistema de pelea, cortina, enemigo, jugador y sus respectivas barras de vida
  SistemaPelea combat;
  Enemigo enemigo;
  Jugador jugador;
  Ui ui; 

  Cortina cortina;
  // Imagen de fondo para el nivel
  PImage background, damage;

  boolean termino, peleaTerminada;
  int fallar;  

  int alphaNivelTerminado, colorEnemigo, alphaEnemigo, alphaRectFondo;
  boolean blancoDibujado, alphaRectFondoCambio, alphaEnemigoZero;

  PImage globoDialogoInicio, globoDialogoFinal;
  int numeroGlobos, alphaGlobo;

  boolean finalListo, finKO;

  String siguienteEtapa;

  boolean musicaNivel;
  
  boolean delay;


  // Constructor
  Nivel(String background, String gato, String perro, String siguienteEtapa) {

    this.siguienteEtapa = siguienteEtapa;

    combat = new SistemaPelea(this, 185, 80, 999, 110);
    jugador = new Jugador(gato, this);
    enemigo = new Enemigo(perro, this);

    ui = new Ui(jugador, enemigo, combat);

    termino = true;

    this.background = loadImage("data/imagenes/niveles/" + background + ".png");
    damage = loadImage("data/imagenes/ui/damage.png");

    cortina = new Cortina(255);

    fallar = 0;

    //Se inicializan las variables que manejan la sucesión de étapas que ocurren al derrotar al enemigo
    alphaNivelTerminado = colorEnemigo = alphaRectFondo = 360;
    blancoDibujado = alphaRectFondoCambio = alphaEnemigoZero = finKO = peleaTerminada = false;
    alphaEnemigo = 255;

    // Se inicializan las variables que controlan el accionar de los "globos de dialogo"
    alphaGlobo = 0;
    numeroGlobos = int(random (0, 11));
    globoDialogoInicio = loadImage("data/imagenes/globosDialogo/" + enemigo.personaje + "/inicio/" + numeroGlobos + ".png");
    globoDialogoFinal = loadImage("data/imagenes/globosDialogo/" + enemigo.personaje +"/final/" + numeroGlobos + ".png");

    minim = new Minim(this);
  
    delay = true;


    musicaNivel = true;
  }

  void dibujar() {

    switch (juego.etapaActual) {

    case "callejon":
      if (musicaNivel == true)
        pausarMusica();

      if (musicaNivel) {
        musicaCallejon.loop();
        musicaNivel = false;
      }
      if (finKO == true)
        pausarMusica();
      break;

    case "mansion": 
      if (musicaNivel == true)
        pausarMusica();

      if (musicaNivel) {
        musicaMansion.loop();
        musicaNivel = false;
      }
      if (finKO == true)
        pausarMusica();
      break;

    case "oficina":
      if (musicaNivel == true)
        pausarMusica();

      if (musicaNivel) {
        musicaOficina.loop();
        musicaNivel = false;
      }
      if (finKO == true)
        pausarMusica();
      break;
    }

    //  println("Alpha Globo" + alphaGlobo);
    // Se limita alphaGlobo para que no exceda ciertos valores
    alphaGlobo = constrain(alphaGlobo, 0, 256);
    cortina.fadeIn();

    imageMode(CORNER);

    pushMatrix();
    if (fallar > 0 ) {

      translate(random(-2, 2), random(-2, 2));
      fallar--;
    }
    pushStyle();
    image(background, 0, 0, width, height);
    // Desde acá empiezan una sucesión de estados que determinan como se comportan los elementos luego de que el jugador haya derrotado al enemigo 

    if (peleaTerminada == true) {
      fill(360, 0 - alphaRectFondo);
      rect(0, 0, width, height);


      if (alphaRectFondo <= 0 && blancoDibujado == false) {
        blancoDibujado = true;
      } else

        if (blancoDibujado == true && colorEnemigo > 0) {
          //   println(colorEnemigo);
          colorEnemigo-=5;
          blancoDibujado = false;
        } else

          if (colorEnemigo <= 0 && alphaRectFondoCambio == false) {
            alphaEnemigo-=3;
            if (alphaEnemigo <= 0) {
              alphaEnemigoZero = true;
            }
          } 

      if (alphaEnemigoZero == true) {
        alphaRectFondoCambio = true;
        enemigo.estado = "vencido";
        alphaRectFondo+=10;
        colorEnemigo+=3;
        alphaEnemigo+=3;
        finalListo = true;
      }

      if (colorEnemigo >= 255 && finalListo == true) {
        if (globoDialogoInicio != null) {
          globoDialogoInicio = null;
        }
        tint(360, alphaGlobo);
        println(alphaGlobo);
        alphaGlobo+=5;
        alphaEnemigoZero = false;
        imageMode(CENTER);
        image(globoDialogoFinal, width/2 + 50, height/2, 344, 193.6);
      }

      if (alphaGlobo >= 255) {
        if (delay) {
          delay(3000);
          delay = false;
        }
        finKO = true;
      }
    }

    // Si el enemigo no fue derrotado, las variables no cambian y tanto el color como el alpha permanecen en sus valores por defecto (360,255)
    tint(colorEnemigo, alphaEnemigo);
    enemigo.dibujar();
    popStyle();

    popMatrix();

    pushStyle ();

    if (ui.textoPreparacion.iniciarPelea == false)
      alphaGlobo+=2;
    tint (255, alphaGlobo);
    if ( globoDialogoInicio != null) {
      imageMode(CENTER);
      image (globoDialogoInicio, width / 2 + 230, height / 2 - 130, 344, 193.6);
    }
    popStyle ();

    if (fallar > 0) {
      pushStyle();
      imageMode(CORNER);
      tint(255, map(fallar, 0, 30, 0, 255));
      image(damage, 0, 0, width, height);
      popStyle();
    }



    if (cortina.listo)
      if (ui.textoPreparacion.iniciarPelea && peleaTerminada == false) {
        if (enemigo.estado == "intro")
          enemigo.estado = "pasivo";
        alphaGlobo -=5;
        combat.pelea();
        combat.reiniciar();
      }

    ui.dibujar();

    cortina.dibujar();

    if (termino) {
      if (jugador.salud <= 0) {
        gameover.trigger();
        cortina.activar("out");
        cortina.fadeOut("gameover");
      } else if (enemigo.salud <= 0) {
        enemigoKO();
      }
    }
  }
  void enemigoKO () {

    ui.alphaRectNivelTerminado -= 1;
    ui.alphaNivelTerminado -= 5;
    if (alphaRectFondoCambio == false) {
      alphaRectFondo-=5;
    }

    if (ui.alphaNivelTerminado <= 10 && ui.alphaRectNivelTerminado <=10) {
      peleaTerminada = true;
    }

    if (finKO == true) {
      cortina.dibujar();
      cortina.activar("out");
      cortina.fadeOut(this.siguienteEtapa);
    }
  }

  void puntos (int ultimoGolpe) {
    if (jugador.personaje == "zarpazo") {
      if (jugador.combo == 0 )
        juego.puntajeJugador += ultimoGolpe;
      else
        juego.puntajeJugador += ultimoGolpe * jugador.combo;
    }
    if (jugador.personaje == "baast") {
      if (jugador.combo == 0 )
        juego.puntajeJugador += ultimoGolpe * 1.5;
      else
        juego.puntajeJugador += ultimoGolpe * jugador.combo * 1.5;
    }
  }
}