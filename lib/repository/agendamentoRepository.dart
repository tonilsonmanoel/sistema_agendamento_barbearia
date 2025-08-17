import 'package:agendamento_barber/models/Agendamento.dart';
import 'package:agendamento_barber/models/Servico.dart';
import 'package:agendamento_barber/repository/servicoRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Agendamentorepository {
  //var db = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  Future<void> criarAgendamento({
    required String nomeCliente,
    required String telefoneCliente,
    required int uidProfissional,
    required String nomeProfissional,
    required String dataString,
    required String diaDaSemana,
    required String horario,
    required double totalAgendamento,
    required DateTime dateTime,
    required List<int> servicos,
    required bool confimado,
  }) async {
    final agendamentoJson = {
      "nomecliente": nomeCliente,
      "telefonecliente": telefoneCliente,
      "idprofissional": uidProfissional,
      "diadasemana": diaDaSemana,
      "horario": horario,
      "datetime": dateTime.toIso8601String(),
      "confimado": confimado,
      "concluido": false,
      "totalagendamento": totalAgendamento,
      "nomeprofissional": nomeProfissional,
      "data": dataString,
    };

    // await db.collection("agendamento").add(agendamentoJson);
    final agendamentoId = await supabase
        .from("agendamentos")
        .insert(agendamentoJson)
        .select("id")
        .single();
    inseriAgendamentoServico(
        servicosId: servicos, agendamentoId: agendamentoId["id"]);
  }

  Future<void> inseriAgendamentoServico(
      {required List<int> servicosId, required int agendamentoId}) async {
    List<Map<String, int>> listaJson = [];
    for (var servico in servicosId) {
      listaJson.add({
        "id_agendamento": agendamentoId,
        "id_servico": servico,
      });
    }

    await supabase.from("agendamentos_servicos").insert(listaJson);
  }

  Future<List<Agendamento>> getAgendamentosProfissionalRepository(
      {required int uidProfissional}) async {
    DateTime dateTimeNow = DateTime.now();
    DateTime data = DateTime(
      dateTimeNow.year,
      dateTimeNow.month,
      dateTimeNow.day,
    );
    /*
    var documentos = await db
        .collection("agendamento")
        .where("uidProfissional", isEqualTo: uidProfissional)
        .where("concluido", isEqualTo: false)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(data))
        .orderBy("datetime")
        .get();
      */

    var documentos = await supabase
        .from("agendamentos")
        .select()
        .eq("idprofissional", uidProfissional)
        .eq("concluido", false)
        .gte("datetime", data.toIso8601String())
        .order("datetime");

    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);
        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }

        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: ${e.toString()}");
      }
    }

    return agentes;
  }

  Future<List<Agendamento>> getAgendamentosProfissionalDateRepository(
      {required int uidProfissional,
      List<DateTime?>? datasSelecionadas}) async {
    var documentos = [];

    if (datasSelecionadas!.length == 2) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("datetime", isGreaterThanOrEqualTo: datasSelecionadas![0])
          .where("datetime", isLessThanOrEqualTo: datasSelecionadas![1])
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
   

    */

      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .gte('datetime', datasSelecionadas[0]!.toIso8601String())
          .lte('datetime', datasSelecionadas[1]!.toIso8601String())
          .eq("concluido", false)
          .order("datetime");
    }
    if (datasSelecionadas.length == 1) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("datetime", isGreaterThanOrEqualTo: datasSelecionadas![0])
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
      */
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .gte('datetime', datasSelecionadas[0]!.toIso8601String())
          .eq("concluido", false)
          .order("datetime");
    }

    if (datasSelecionadas[0] == null) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
      */
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .eq("concluido", false)
          .order("datetime");
    }

    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        print(" datetime: ${documentos[i]["datetime"]}");
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);
        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }

        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: $e");
      }
    }

    return agentes;
  }

  Future<List<Agendamento>> getAgendamentosRealizadosProfissional(
      {required int uidProfissional, String? buscar = ""}) async {
    /*
    var documentos = await db
        .collection("agendamento")
        .where("uidProfissional", isEqualTo: uidProfissional)
        .where("concluido", isEqualTo: true)
        .orderBy("datetime")
        .get();
      */
    var documentos = await supabase
        .from("agendamentos")
        .select()
        .eq("idprofissional", uidProfissional)
        .eq("concluido", true)
        .ilike("nomecliente", '%%')
        .order("datetime");
    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);

        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }

        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: $e");
      }
    }

    return agentes;
  }

  Future<List<Agendamento>> getAgendamentosRealizadosDateProfissional(
      {required int uidProfissional,
      List<DateTime?>? datasSelecionadas}) async {
    var documentos = [];

    if (datasSelecionadas!.length == 2) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("datetime", isGreaterThanOrEqualTo: datasSelecionadas![0])
          .where("datetime", isLessThanOrEqualTo: datasSelecionadas![1])
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
   

    */

      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .gte('datetime', datasSelecionadas[0]!.toIso8601String())
          .lte('datetime', datasSelecionadas[1]!.toIso8601String())
          .eq("concluido", true)
          .order("datetime");
    }
    if (datasSelecionadas.length == 1) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("datetime", isGreaterThanOrEqualTo: datasSelecionadas![0])
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
      */
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .gte('datetime', datasSelecionadas[0]!.toIso8601String())
          .eq("concluido", true)
          .order("datetime");
    }

    if (datasSelecionadas[0] == null) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
      */
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .eq("concluido", true)
          .order("datetime");
    }

    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);
        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }

        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: $e");
      }
    }

    return agentes;
  }

  Future<List<Agendamento>> getAgendamentosNaoConcluidos({
    required int uidProfissional,
  }) async {
    /*
    var documentos = await db
        .collection("agendamento")
        .where("uidProfissional", isEqualTo: uidProfissional)
        .where("datetime",
            isLessThanOrEqualTo: DateTime.now().add(Duration(days: 1)))
        .where("concluido", isEqualTo: false)
        .orderBy("datetime")
        .get();

    */
    var documentos = await supabase
        .from("agendamentos")
        .select()
        .eq("idprofissional", uidProfissional)
        .lte(
            "datetime", DateTime.now().add(Duration(days: 1)).toIso8601String())
        .eq("concluido", false)
        .order("datetime");
    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);
        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }

        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: $e");
      }
    }

    return agentes;
  }

  Future<List<Agendamento>> getAgendamentosNaoConcluidosDate(
      {required int uidProfissional,
      List<DateTime?>? datasSelecionadas}) async {
    var documentos = [];

    if (datasSelecionadas!.length == 2) {
      /*
      documentos = await db
          .collection("agendamento")
          .where("uidProfissional", isEqualTo: uidProfissional)
          .where("datetime", isGreaterThanOrEqualTo: datasSelecionadas![0])
          .where("datetime", isLessThanOrEqualTo: datasSelecionadas![1])
          .where("concluido", isEqualTo: true)
          .orderBy("datetime")
          .get();
   

    */
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .lte("datetime",
              DateTime.now().add(Duration(days: 1)).toIso8601String())
          .gte('datetime', datasSelecionadas[0]!.toIso8601String())
          .lte('datetime', datasSelecionadas[1]!.toIso8601String())
          .eq("concluido", true)
          .order("datetime");
    }
    if (datasSelecionadas.length == 1) {
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .lte("datetime",
              DateTime.now().add(Duration(days: 1)).toIso8601String())
          .gte('datetime', datasSelecionadas[0]!.toIso8601String())
          .eq("concluido", true)
          .order("datetime");
    }

    if (datasSelecionadas[0] == null) {
      documentos = await supabase
          .from("agendamentos")
          .select()
          .eq("idprofissional", uidProfissional)
          .lte("datetime",
              DateTime.now().add(Duration(days: 1)).toIso8601String())
          .eq("concluido", true)
          .order("datetime");
    }

    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);
        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }

        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: $e");
      }
    }
    return agentes;
  }

  Future<List<Agendamento>> getAgendamentosProfissionalLimite(
      {required int uidProfissional, required int limite}) async {
    DateTime dateTimeNow = DateTime.now();
    DateTime data = DateTime(
      dateTimeNow.year,
      dateTimeNow.month,
      dateTimeNow.day,
    );

    var documentos = await supabase
        .from("agendamentos")
        .select()
        .eq("idprofissional", uidProfissional)
        .gte("datetime", data.toIso8601String())
        .eq("concluido", false)
        .limit(limite)
        .order("datetime", ascending: true);
    List<Agendamento> agentes = [];
    for (var i = 0; i < documentos.length; i++) {
      try {
        final data = documentos[i]["datetime"];

        DateTime date = DateTime.parse(data);

        var servicosResult = await Servicorepository()
            .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

        List<Servico> servicos = [];

        for (var s in servicosResult) {
          servicos.add(Servico(
              nome: s.nome,
              valor: s.valor,
              urlImg: s.urlImg,
              ativo: s.ativo,
              ativoLadingpage: s.ativoLadingpage,
              idProfissional: s.idProfissional,
              uid: s.uid));
        }
        Agendamento agendamento = Agendamento(
            uid: documentos[i]["id"],
            uidProfissional: documentos[i]["idprofissional"],
            data: documentos[i]["data"],
            horario: documentos[i]["horario"],
            dateTimeAgenda: date,
            diaDaSemana: documentos[i]["diadasemana"],
            concluido: documentos[i]["concluido"],
            confimado: documentos[i]["confimado"],
            nomeCliente: documentos[i]["nomecliente"],
            totalAgendamento: documentos[i]["totalagendamento"],
            nomeProfissional: documentos[i]["nomeprofissional"],
            telefoneCliente: documentos[i]["telefonecliente"],
            servicos: servicos);

        agentes.add(agendamento);
      } catch (e) {
        print("Erro ao processar documento $i: $e");
      }
    }

    return agentes;
  }

  Future<int> countAgendamentosMes({required int uidProfissional}) async {
    DateTime dateNow = DateTime.now();
    DateTime inicio = DateTime(dateNow.year, dateNow.month, 1);

    DateTime fim = DateTime(dateNow.year, dateNow.month + 1, 1)
        .subtract(Duration(microseconds: 1));

    var documentos = await supabase
        .from("agendamentos")
        .select()
        .eq("idprofissional", uidProfissional)
        .gte("datetime", inicio.toIso8601String())
        .lte("datetime", fim.toIso8601String())
        .order("datetime")
        .count();
    return documentos.count;
  }

  Future<int> countAgendamentoDia({required int uidProfissional}) async {
    DateTime dateNow = DateTime.now();
    DateTime inicio = DateTime(dateNow.year, dateNow.month, dateNow.day);

    DateTime fim = DateTime(dateNow.year, dateNow.month, dateNow.day + 1)
        .subtract(Duration(microseconds: 1));

    var documentos = await supabase
        .from("agendamentos")
        .select()
        .eq("idprofissional", uidProfissional)
        .gte("datetime", inicio.toIso8601String())
        .lte("datetime", fim.toIso8601String())
        .eq("concluido", false)
        .order("datetime")
        .count();
    return documentos.count;
  }

  Future<double> totalFaturamentoMes({required int idProfissional}) async {
    DateTime datenow = DateTime.now();

    final inicioMes = DateTime(datenow.year, datenow.month, 1);
    final fimMes = DateTime(datenow.year, datenow.month + 1, 0);

    final response = await supabase
        .from('agendamentos')
        .select("totalagendamento")
        .eq("concluido", true)
        .eq("idprofissional", idProfissional)
        .gte('datetime', inicioMes.toIso8601String()) // >= início do mês
        .lte('datetime', fimMes.toIso8601String()) // <= final do mês
        .order('datetime', ascending: true);

    if (response.isEmpty) {
      return 0;
    } else {
      double faturamentoMes = 0;
      for (var i in response) {
        faturamentoMes += i["totalagendamento"];
      }
      return faturamentoMes;
    }
  }

  Future<List<Agendamento>> buscarAgendamentosRepository(
      {required String telefoneCliente}) async {
    List<Agendamento> agendamentos = [];

    var documentos = await supabase
        .from("agendamentos")
        .select("*,agendamentos_servicos(*)")
        .eq("telefonecliente", telefoneCliente)
        .eq("concluido", false)
        .order("datetime");

    for (var i = 0; i < documentos.length; i++) {
      String dataString = documentos[i]["datetime"];
      DateTime date = DateTime.parse(dataString);

      var servicosResult = await Servicorepository()
          .getServicosAgendamento(idAgendamento: documentos[i]["id"]);

      List<Servico> servicos = [];

      for (var s in servicosResult) {
        servicos.add(Servico(
            nome: s.nome,
            valor: s.valor,
            urlImg: s.urlImg,
            ativo: s.ativo,
            ativoLadingpage: s.ativoLadingpage,
            idProfissional: s.idProfissional,
            uid: s.uid));
      }

      Agendamento agendamento = Agendamento(
          uid: documentos[i]["id"],
          uidProfissional: documentos[i]["idprofissional"],
          data: documentos[i]["data"],
          horario: documentos[i]["horario"],
          dateTimeAgenda: date,
          diaDaSemana: documentos[i]["diadasemana"],
          concluido: documentos[i]["concluido"],
          confimado: documentos[i]["confimado"],
          nomeCliente: documentos[i]["nomecliente"],
          totalAgendamento: documentos[i]["totalagendamento"],
          nomeProfissional: documentos[i]["nomeprofissional"],
          telefoneCliente: documentos[i]["telefonecliente"],
          servicos: servicos);

      agendamentos.add(agendamento);
    }

    return agendamentos;
  }

  Future<List<String>> buscarHorariosOcupadosRepository(
      {required String data, required int uidProfissional}) async {
    var documentos = await supabase
        .from("agendamentos")
        .select("horario")
        .eq("data", data)
        .eq("idprofissional", uidProfissional);
    List<String> listaHorariosOcupado = [];

    for (var i = 0; i < documentos.length; i++) {
      listaHorariosOcupado.add(documentos[i]["horario"]);
    }

    return listaHorariosOcupado;
  }

  Future<List<String>> buscarHorariosdisponiveisProfissional(
      {required String data, required int uidProfissional}) async {
    var documentos = await supabase
        .from("agendamentos")
        .select("horario")
        .eq("data", data)
        .eq("idprofissional", uidProfissional);
    List<String> listaHorariosOcupado = [];

    for (var i = 0; i < documentos.length; i++) {
      listaHorariosOcupado.add(documentos[i]["horario"]);
    }

    var documentsHorariosProfissional = await supabase
        .from('profissional_horarios')
        .select('hora,ativado')
        .eq('id_profissional', uidProfissional);

    List<String> listaHorariosProfisional = [];
    for (var horario in documentsHorariosProfissional) {
      if (horario["ativado"] == true) {
        listaHorariosProfisional.add(horario["hora"]);
      }
    }

    // Passo 3: Filtrar horários disponíveis
    final horariosDisponiveis = listaHorariosProfisional
        .where((horario) => !listaHorariosOcupado.contains(horario))
        .toList();

    return horariosDisponiveis;
  }

  Future<void> updateAgendamentoRepository(
      {required Agendamento agendamento,
      required int uidAgendamento,
      required double totalAgendamento}) async {
    final agendamentoJson = {
      "nomecliente": agendamento.nomeCliente,
      "telefonecliente": agendamento.telefoneCliente,
      "idprofissional": agendamento.uidProfissional,
      "diadasemana": agendamento.diaDaSemana,
      "horario": agendamento.horario,
      "datetime": agendamento.dateTimeAgenda.toIso8601String(),
      "confimado": agendamento.confimado,
      "concluido": agendamento.concluido,
      "totalagendamento": totalAgendamento,
      "nomeprofissional": agendamento.nomeProfissional,
      "data": agendamento.data,
    };

    await supabase
        .from("agendamentos")
        .update(agendamentoJson)
        .eq("id", uidAgendamento);
  }

  Future<void> deleteProfissionalRepository(
      {required int uidAgendamento}) async {
    await supabase.from("agendamentos").delete().eq('id', uidAgendamento);
  }
}
