enum DiaDaSemana {
  segunda(1),
  terca(2),
  quarta(3),
  quinta(4),
  sexta(5);

  final int value;
  const DiaDaSemana(this.value);

  static DiaDaSemana? fromValue(int value) {
    try {
      return DiaDaSemana.values.firstWhere((dia) => dia.value == value);
    } catch (e) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case DiaDaSemana.segunda:
        return 'Segunda-feira';
      case DiaDaSemana.terca:
        return 'Terça-feira';
      case DiaDaSemana.quarta:
        return 'Quarta-feira';
      case DiaDaSemana.quinta:
        return 'Quinta-feira';
      case DiaDaSemana.sexta:
        return 'Sexta-feira';
    }
  }
}


