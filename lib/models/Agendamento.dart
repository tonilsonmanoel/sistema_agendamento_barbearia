import 'package:agendamento_barber/models/Servico.dart';

class Agendamento {
  int? uid;
  String nomeCliente;
  String telefoneCliente;
  int uidProfissional;
  String nomeProfissional;
  String data;
  String diaDaSemana;
  String horario;
  DateTime dateTimeAgenda;
  List<Servico> servicos;
  bool confimado;
  bool? concluido;
  double totalAgendamento;
  Agendamento({
    required this.uidProfissional,
    required this.data,
    required this.horario,
    required this.dateTimeAgenda,
    required this.servicos,
    required this.diaDaSemana,
    required this.confimado,
    this.concluido,
    this.uid,
    required this.totalAgendamento,
    required this.nomeCliente,
    required this.nomeProfissional,
    required this.telefoneCliente,
  });
}
