class Mensaje {
  var property emisor = nadie
  const property contenido

  method peso() = 5 + contenido.peso() * 1.3

  method enviarse(usuario, chat) {
    emisor = usuario
    chat.recibir(self)
  }

  method contieneTexto(texto) = contenido.contieneTexto(texto)
}

class Contenido {
  method contieneTexto(texto) = false
}

class Texto inherits Contenido {
  const caracteres

  method peso() = caracteres.size()
  override method contieneTexto(texto) = caracteres.contains(texto)
}

class Audio inherits Contenido {
  const duracion

  method peso() = duracion * 1.2
}

class Imagen inherits Contenido {
  const property alto
  const property ancho
  const modoDeCompresion

  method pixeles() = alto * ancho
  method peso() = modoDeCompresion.comprimir(self.pixeles()) * 2
}

class GIF inherits Imagen {
  const cuadros

  override method peso() = super() * cuadros
}

class Original {
  method comprimir(pixeles) = pixeles
}

class Variable {
  const porcentaje

  method comprimir(pixeles) = pixeles * porcentaje
}

class Maxima {
  method comprimir(pixeles) = pixeles.min(10000)
}

class Contacto {
  const property usuario

  method peso() = 3 
}

class Usuario {
  var property memoria = 100000
  const property chats = []
  const notificaciones = []

  method enviar(mensaje, chat) = mensaje.enviarse(self, chat)

  method espacioLibre(mensaje) = mensaje.peso() <= memoria

  method agregarChat(chat) = chats.add(chat)

  method buscarTexto(texto) = chats.filter({chat => chat.contieneTexto(texto)})

  method mensajesMasPesados() = chats.map({chat => chat.mensajeMasPesado()})

  method agregarNotificacion(notificacion) = notificaciones.add(notificacion)

  method notificacionesProvenientes(chat) = notificaciones.filter({notificacion => notificacion.chat() == chat})

  method leerChat(chat) {
    self.notificacionesProvenientes(chat).forEach({notificacion => notificacion.leer()})
  }

  method noLeidos() = notificaciones.filter({notificacion => !(notificacion.leido())})
}

class Chat {
  const participantes = []
  const property mensajes = []

  method aceptaEmisor(emisor) = participantes.contains(emisor)
  method aceptaMensaje(mensaje) = participantes.all({persona => persona.espacioLibre(mensaje)})
  method acepta(mensaje) = self.aceptaEmisor(mensaje.emisor()) && self.aceptaMensaje(mensaje)

  method agregarMensaje(mensaje) {
    mensajes.add(mensaje)
    participantes.forEach({persona => persona.memoria(persona.memoria() - mensaje.peso())})
  }

  method recibir(mensaje) {
    if (self.acepta(mensaje))
      self.agregarMensaje(mensaje)
      participantes.forEach({persona => persona.agregarNotificacion(new Notificacion(chat = self))})
  }

  method espacio() = mensajes.sum({mensaje => mensaje.peso()})
  method contieneTexto(texto) = mensajes.any({mensaje => mensaje.contieneTexto(texto)})
  method mensajeMasPesado() = mensajes.max({mensaje => mensaje.peso()})
}

class ChatPremium inherits Chat {
  var property creador
  var property permiso

  override method acepta(mensaje) = super(mensaje) && permiso.permitePara(mensaje, self)

  method agregarParticipante(persona) {
    if (!(participantes.contains(persona)))
      participantes.add(persona)
  }
}

class Difusion {
  method permitePara(mensaje, chat) = mensaje.emisor() == chat.creador()
}

class Restringido {
  const limite

  method  permitePara(mensaje, chat) = mensaje.peso() <= limite
}

class Ahorro inherits ChatPremium {
  const pesoMaximo

  override method aceptaMensaje(mensaje) = super(mensaje) && mensaje.peso() <= pesoMaximo
}

class Notificacion {
  const property chat
  var property leido = false

  method leer() {
    leido = true
  }
}

object nadie {}