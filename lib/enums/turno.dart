enum Turno {
  matutino(1),
  vespertino(2),
  noturno(3);

  final int value;
  const Turno(this.value);

  static Turno? fromValue(int value) {
    try {
      return Turno.values.firstWhere((turno) => turno.value == value);
    } catch (e) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case Turno.matutino:
        return 'Matutino';
      case Turno.vespertino:
        return 'Vespertino';
      case Turno.noturno:
        return 'Noturno';
    }
  }
}


