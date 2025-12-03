enum Status {
  aguardandoAp(1),
  aprovado(2),
  negado(3),
  cancelado(4);

  final int value;
  const Status(this.value);

  static Status? fromValue(int value) {
    try {
      return Status.values.firstWhere((status) => status.value == value);
    } catch (e) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case Status.aguardandoAp:
        return 'Aguardando Aprovação';
      case Status.aprovado:
        return 'Aprovado';
      case Status.negado:
        return 'Negado';
      case Status.cancelado:
        return 'Cancelado';
    }
  }
}


