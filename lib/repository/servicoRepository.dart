import 'package:agendamento_barber/models/Servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Servicorepository {
  var db = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  Future<void> createServicoRepository(
      {required Servico servico, required int uidProfissional}) async {
    final servicoJson = {
      "nome": servico.nome,
      "valor": servico.valor,
      "urlimg": servico.urlImg,
      "ativo": servico.ativo,
      "id_profissional": uidProfissional,
      "ativo_ladingpage": servico.ativoLadingpage,
    };

    /*
    var docColetion = await db.collection("profissional").doc(uidProfissional);
    await docColetion.collection("servicos").add(servicoJson);
   */
    await supabase.from("servicos").insert(servicoJson);
  }

  Future<List<Servico>> getListaServicosRepository(
      {required int uidProfissional}) async {
    /*
    var documentos = await db
        .collection("profissional")
        .doc(uidProfissional)
        .collection("servicos")
        .get();
        */
    var documentos = await supabase
        .from("servicos")
        .select()
        .eq("id_profissional", uidProfissional);

    List<Servico> servicos = [];
    for (var i = 0; i < documentos.length; i++) {
      Servico servico = Servico(
          uid: documentos[i]["id"],
          nome: documentos[i]["nome"],
          valor: documentos[i]["valor"],
          urlImg: documentos[i]["urlimg"],
          idProfissional: documentos[i]["id_profissional"],
          ativoLadingpage: documentos[i]["ativo_ladingpage"],
          ativo: documentos[i]["ativo"]);

      servicos.add(servico);
    }
    return servicos;
  }

  Future<List<Servico>> getServicosLandingPage() async {
    /*
    var documentos = await db
        .collection("profissional")
        .doc(uidProfissional)
        .collection("servicos")
        .get();
        */
    var documentos =
        await supabase.from("servicos").select().eq("ativo_ladingpage", true);

    List<Servico> servicos = [];
    for (var i = 0; i < documentos.length; i++) {
      Servico servico = Servico(
          uid: documentos[i]["id"],
          nome: documentos[i]["nome"],
          valor: documentos[i]["valor"],
          urlImg: documentos[i]["urlimg"],
          idProfissional: documentos[i]["id_profissional"],
          ativoLadingpage: documentos[i]["ativo_ladingpage"],
          ativo: documentos[i]["ativo"]);

      servicos.add(servico);
    }
    return servicos;
  }

  Future<List<Servico>> getServicosAgendamento(
      {required int idAgendamento}) async {
    var documentos = await supabase
        .from("agendamentos_servicos")
        .select("*,servicos(*)")
        .eq("id_agendamento", idAgendamento);

    List<Servico> servicos = [];

    for (var i = 0; i < documentos.length; i++) {
      Servico servico = Servico(
          uid: documentos[i]["servicos"]["id"],
          nome: documentos[i]["servicos"]["nome"],
          valor: documentos[i]["servicos"]["valor"],
          urlImg: documentos[i]["servicos"]["urlimg"],
          ativoLadingpage: documentos[i]["servicos"]["ativo_ladingpage"],
          idProfissional: documentos[i]["servicos"]["id_profissional"],
          ativo: documentos[i]["servicos"]["ativo"]);
      servicos.add(servico);
    }

    return servicos;
  }

  Future<void> updateServicoRepository({
    required Servico servico,
    required int uidServico,
  }) async {
    var servico_json = {
      "nome": servico.nome,
      "valor": servico.valor,
      "urlimg": servico.urlImg,
      "ativo": servico.ativo,
      "ativo_ladingpage": servico.ativoLadingpage,
      "id_profissional": servico.idProfissional
    };
    /*
    await db
        .collection("profissional")
        .doc(uidProfissional)
        .collection("servicos")
        .doc(uidServico)
        .update(servico_json)
        .then(
      (value) {
        print(
            "servico atualiado id:$uidServico, uidProfissional: $uidProfissional");
      },
    );*/
    await supabase.from("servicos").update(servico_json).eq("id", uidServico);
  }

  Future<void> deleteServicoRepository({required int uidServico}) async {
    /*
    await db .collection("profissional") .doc(uidProfissional) .collection("servicos")  .doc(uidServico) .delete()
        .then(
          (value) => print("servico deletado"),
        );
    */
    await supabase.from("servicos").delete().eq("id", uidServico);
  }
}
