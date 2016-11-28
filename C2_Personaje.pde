class Personaje { //<>//
  // Datos
  int salud, saludMaxima, combo, damage, damageActual, tamX, tamY;

  // Nombre del personaje. Se utiliza para referenciar al personaje.
  String personaje;
  boolean jugador;

  // Función para infligir daño al enemigo
  void infligirDamage(Personaje personaje) {
    if (this.personaje == "zarpazo") {
      damage = damageActual + int((combo * 1.6));
      personaje.salud -= damageActual + int((combo * 1.6));
    } else if (this.personaje == "baast") {
      damage = damageActual + int((combo * 1.2));
      personaje.salud -= damageActual + int((combo * 1.2));
    } else {
      damage = damageActual + int((combo * 1.4));
      personaje.salud -= damageActual + int((combo * 1.4));
    }
  }
  void comboBreak() {
    if (combo == 0) {
      damageActual = 0;
    }
  }
}


class Jugador extends Personaje {
  // Variable para almacenar la cantidad de puntos
  int puntos;

  PImage[] guantes;

  //Constructor
  Jugador(String personaje) {
    this.personaje = personaje;

    if (personaje == "zarpazo")
      salud = saludMaxima = 5000;
    else
      salud = saludMaxima = 4000; 

    combo = damage = damageActual = 0;
    jugador = true;
    puntos = 0;
  }
}

class Enemigo extends Personaje {
  PImage[] pasivo;
  PImage[] golpeando;
  int pasivoCount;
  int golpeandoCount;
  int frame, millis;

  String estado;

  boolean terminoP, terminoG;

  //Constructor
  Enemigo(String personaje) {
    // Según el personaje, se cargan las diferentes imagenes
    this.personaje = personaje;

    // Variables comunes 
    jugador = false;
    estado = "pasivo";
    combo = damage = damageActual = 0;

    // Variables para cerbero
    if (personaje == "cerbero") {
      salud = saludMaxima = 7000;
      tamX = 583;
      tamY = 768;

      // Cantidad de imagenes
      pasivoCount = 5;
      golpeandoCount = 8;
    }

    pasivo = new PImage[pasivoCount];
    golpeando = new PImage[golpeandoCount];

    // Estados para los sprites
    frame = 0;
    terminoP = true;
    terminoG = true;

    // Loops para cargar los diferentes sprites
    for (int i = 0; i < pasivoCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = "data/imagenes/personajes/" + personaje + "/pasivo/"+ i + ".png";
      pasivo[i] = loadImage(filename);
    }
    for (int i = 0; i < golpeandoCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = "data/imagenes/personajes/" + personaje + "/golpeando/" + i + ".png";
      golpeando[i] = loadImage(filename);
    }
  }

  // Métodos
  void dibujar(float posX, float posY, float tamX, float tamY) {
    if (estado == "pasivo") {
      pasivo(); 
      imageMode(CENTER);
      image(pasivo[frame], posX, posY, tamX, tamY);
    }
    if (estado == "golpeando") {
      golpeando();
      imageMode(CENTER);
      image(golpeando[frame], posX, posY, tamX, tamY);
    }
  }

  void pasivo() {
    if (terminoP) {
      millis = millis();
      terminoP = false;
    }    
    if (!terminoP) {
      if (millis() <  millis + 100) frame = 0;
      if (millis() >  millis + 100 && millis() < millis + 200) frame = 1;
      if (millis() >  millis + 200 && millis() < millis + 300) frame = 2;
      if (millis() >  millis + 300 && millis() < millis + 400) frame = 3;
      if (millis() >  millis + 400 && millis() < millis + 500) frame = 4;
      if (millis() >  millis + 500 && millis() < millis + 600) frame = 3;
      if (millis() >  millis + 600 && millis() < millis + 700) frame = 2;
      if (millis() > millis + 700) terminoP = true;
    }
  }
  void golpeando() {
    if (terminoG) {
      millis = millis();
      terminoG = false;
    }    
    if (terminoG == false) {
      if (millis() <  millis + 50) frame = 0;
      if (millis() >  millis + 50 && millis() < millis + 100) frame = 1;
      if (millis() >  millis + 100 && millis() < millis + 150) frame = 2;
      if (millis() >  millis + 150 && millis() < millis + 200) frame = 3;
      if (millis() >  millis + 250 && millis() < millis + 300) frame = 4;
      if (millis() >  millis + 350 && millis() < millis + 400) frame = 5;
      if (millis() >  millis + 450 && millis() < millis + 500) frame = 6;
      if (millis() >  millis + 550 && millis() < millis + 600) frame = 7;

      if (millis() > millis + 600) {
        terminoP = true;
        estado = "pasivo";
      }
    }
  }
}