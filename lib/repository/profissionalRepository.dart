import 'package:agendamento_barber/models/Profissional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xor_encryption/xor_encryption.dart';

class Profissionalrepository {
  var db = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;
  //Metodos Login

  Future<Map<String, dynamic>> getLoginProfissional(
      {required String email,
      required String senha,
      required int idEstabelecimento}) async {
    String mensagem = "Email ou senhas incorreto";
    Profissional? profissional;
    //var documents = await db.collection("profissional").where("email", isEqualTo: email) .where("senha", isEqualTo: senha) .get();

    var documents =
        await supabase.from("profissionais").select().eq("email", email);
    if (documents.isNotEmpty) {
      final decrypted = XorCipher()
          .encryptData(documents.first['senha'], documents.first['keyhash']);

      if (senha == decrypted) {
        List<Map<String, dynamic>> listaDiasDaSemanaResultado =
            await getDiasTrabalhoProfissional(
                idProfissional: documents.first['id']);
        List<Map<String, dynamic>> listaHorariosResultado =
            await geHorariosProfissional(idProfissional: documents.first['id']);

        profissional = Profissional(
            uid: documents.first['id'],
            nome: documents.first["nome"],
            email: documents.first["email"],
            telefone: documents.first["telefone"],
            telefoneWhatsapp: documents.first["telefonewhatsapp"],
            fotoPerfil: documents.first["fotoperfil"],
            perfil: documents.first["perfil"],
            idEstabelecimento: documents.first["idestabelecimento"],
            horariosTrabalho:
                listaHorariosResultado.cast<Map<String, dynamic>>(),
            diasTrabalho:
                listaDiasDaSemanaResultado.cast<Map<String, dynamic>>(),
            status: documents.first["status"]);

        mensagem = "Login realizado";
      }
    }

    return {
      "profissinalObjeto": profissional,
      "mensagem": mensagem,
    };
  }

  Future<Map<String, dynamic>> verificarEmailExistir(
      {required String email, required int idEstabelecimento}) async {
    //var documents = await db.collection("profissional").where("email", isEqualTo: email) .where("senha", isEqualTo: senha) .get();

    var documents = await supabase
        .from("profissionais")
        .select('id')
        .eq("email", email)
        .single();

    if (documents.isNotEmpty) {
      return {
        "id": documents["id"],
      };
    }

    return {
      "id": null,
    };
  }

  Future<Profissional?> getProfissional({required int id}) async {
    Profissional? profissional;
    //var documents = await db.collection("profissional").where("email", isEqualTo: email) .where("senha", isEqualTo: senha) .get();

    var documents =
        await supabase.from("profissionais").select().eq("id", id).single();

    if (documents.isNotEmpty) {
      List<Map<String, dynamic>> listaDiasDaSemanaResultado =
          await getDiasTrabalhoProfissional(idProfissional: documents['id']);
      List<Map<String, dynamic>> listaHorariosResultado =
          await geHorariosProfissional(idProfissional: documents['id']);

      profissional = Profissional(
          uid: documents['id'],
          nome: documents["nome"],
          email: documents["email"],
          telefone: documents["telefone"],
          telefoneWhatsapp: documents["telefonewhatsapp"],
          fotoPerfil: documents["fotoperfil"],
          perfil: documents["perfil"],
          idEstabelecimento: documents["idestabelecimento"],
          horariosTrabalho: listaHorariosResultado.cast<Map<String, dynamic>>(),
          diasTrabalho: listaDiasDaSemanaResultado.cast<Map<String, dynamic>>(),
          status: documents["status"]);
    }
    return profissional;
  }

  Future<void> createProfissionalRepository(
      {required Profissional profissional, required String senha}) async {
    final String key = XorCipher().getSecretKey(20);

    final encrypted = XorCipher().encryptData(senha, key);
    var profissionalJson = {
      "nome": profissional.nome,
      "email": profissional.email,
      "telefone": profissional.telefone,
      "telefonewhatsapp": profissional.telefoneWhatsapp,
      "fotoperfil": profissional.fotoPerfil,
      "status": profissional.status,
      "perfil": profissional.perfil,
      "senha": encrypted,
      "keyhash": key,
      "idestabelecimento": profissional.idEstabelecimento
    };

    //await db.collection("profissional").add(profissionalJson);
    final idProfissional = await supabase
        .from("profissionais")
        .insert(profissionalJson)
        .select('id')
        .single();
    createDiasProfissional(
        idProfissional: idProfissional['id'], profissional: profissional);
    createHorariosProfissional(
        idProfissional: idProfissional['id'], profissional: profissional);
  }

  Future<void> createDiasProfissional(
      {required int idProfissional, required Profissional profissional}) async {
    for (var dia in profissional.diasTrabalho) {
      dia["profissional_id"] = idProfissional;
    }

    await supabase.from("profissional_dias").insert(profissional.diasTrabalho);
  }

  Future<void> createHorariosProfissional(
      {required int idProfissional, required Profissional profissional}) async {
    for (var horario in profissional.horariosTrabalho) {
      horario["id_profissional"] = idProfissional;
    }

    await supabase
        .from("profissional_horarios")
        .insert(profissional.horariosTrabalho);
  }

  //Fim metodos Login
  /*
  Future<List<DocumentSnapshot>> getFuncionariosRepository() async {
    //var documents = await db.collection("profissional").get();

    return documents.docs;
  }

*/
  Future<List<Profissional>> getFuncionariosDisponivelRepository(
      {required String diaDaSemana}) async {
    /*
    var documents = await db
        .collection("profissional")
        .where("diasTrabalho", arrayContainsAny: [
      {
        "dia": diaDaSemana,
        "ativado": true,
      }
    ]).get();
*/
    List<Profissional> profissionais = [];
    var documentsProfissionais = await supabase.from("profissionais").select();

    for (var profissional in documentsProfissionais) {
      var documentsDiaHorario = await supabase
          .from("profissional_dias")
          .select()
          .eq("profissional_id", profissional['id'])
          .eq("dia", diaDaSemana)
          .eq('ativado', true)
          .limit(1);

      if (documentsDiaHorario.isNotEmpty) {
        List<Map<String, dynamic>> listaDiasDaSemanaResultado =
            await getDiasTrabalhoProfissional(
                idProfissional: profissional['id']);
        List<Map<String, dynamic>> listaHorariosResultado =
            await geHorariosProfissional(idProfissional: profissional['id']);

        Profissional profissionalObjeto = Profissional(
            uid: profissional['id'],
            nome: profissional["nome"],
            email: profissional["email"],
            perfil: profissional["perfil"],
            telefone: profissional["telefone"],
            telefoneWhatsapp: profissional["telefonewhatsapp"],
            fotoPerfil: profissional["fotoperfil"],
            idEstabelecimento: profissional["idestabelecimento"],
            horariosTrabalho:
                listaHorariosResultado.cast<Map<String, dynamic>>(),
            diasTrabalho:
                listaDiasDaSemanaResultado.cast<Map<String, dynamic>>(),
            status: profissional["status"]);

        profissionais.add(profissionalObjeto);
      }
    }

    print("profissionais: ${profissionais.length}");

    return profissionais;
  }

  Future<List<Map<String, dynamic>>> getDiasTrabalhoProfissional(
      {required int idProfissional}) async {
    var documents = await supabase
        .from("profissional_dias")
        .select("dia,ativado")
        .eq("profissional_id", idProfissional);

    List<Map<String, dynamic>> listaDiasDaSemana = [];

    for (var dia in documents) {
      listaDiasDaSemana.add({
        "dia": dia["dia"],
        "ativado": dia["ativado"],
      });
    }

    return listaDiasDaSemana;
  }

  Future<List<Map<String, dynamic>>> geHorariosProfissional(
      {required int idProfissional}) async {
    var documents = await supabase
        .from('profissional_horarios')
        .select('hora,ativado')
        .eq('id_profissional', idProfissional);

    List<Map<String, dynamic>> listaHorarios = [];
    for (var hora in documents) {
      listaHorarios.add({
        "hora": hora["hora"],
        "ativado": hora["ativado"],
      });
    }

    return listaHorarios;
  }

  Future<List<Profissional>> getTodosBarbeiros() async {
    // var documents = await db.collection("profissional").get();
    var documents = await supabase.from("profissionais").select();
    List<Profissional> profissionais = [];

    for (var profissional in documents) {
      List<Map<String, dynamic>> listaDiasDaSemanaResultado =
          await getDiasTrabalhoProfissional(idProfissional: profissional['id']);
      List<Map<String, dynamic>> listaHorariosResultado =
          await geHorariosProfissional(idProfissional: profissional['id']);
      profissionais.add(Profissional(
          uid: profissional['id'],
          nome: profissional["nome"],
          email: profissional["email"],
          perfil: profissional["perfil"],
          telefone: profissional["telefone"],
          telefoneWhatsapp: profissional["telefonewhatsapp"],
          fotoPerfil: profissional["fotoperfil"],
          idEstabelecimento: profissional["idestabelecimento"],
          horariosTrabalho: listaHorariosResultado.cast<Map<String, dynamic>>(),
          diasTrabalho: listaDiasDaSemanaResultado.cast<Map<String, dynamic>>(),
          status: profissional["status"]));
    }

    return profissionais;
  }

  Future<List<Map<String, dynamic>>> getBarbeirosLandingPage() async {
    // var documents = await db.collection("profissional").get();
    var documents = await supabase
        .from("profissionais")
        .select('id,nome,fotoperfil,status');

    List<Map<String, dynamic>> barbeiros = [];
    for (var profissional in documents) {
      var jsonBarbeiro = {
        "id": profissional['id'],
        "nome": profissional["nome"],
        "fotoperfil": profissional["fotoperfil"],
        "status": profissional["status"],
      };
      barbeiros.add(jsonBarbeiro);
    }

    return barbeiros;
  }

  Future<List<String>> getHorariosProfissional(
      {required int uidProfissional}) async {
    // var documents = await db.collection("profissional").doc(uidProfissional).get();
    var documents = await supabase
        .from("profissional_horarios")
        .select()
        .eq("id_profissional", uidProfissional);
    List<String> horariosProfissional = [];
    for (var horario in documents) {
      if (horario["ativado"] == true) {
        horariosProfissional.add(horario["hora"]);
      }
    }

    return horariosProfissional;
  }

  Future<void> updateProfissionalRepository(
      {required Profissional profissional,
      required int uidProfissional}) async {
    var profissionalJson = {
      "nome": profissional.nome,
      "email": profissional.email,
      "telefone": profissional.telefone,
      "telefonewhatsapp": profissional.telefoneWhatsapp,
      "fotoperfil": profissional.fotoPerfil,
      "perfil": profissional.perfil,
      "status": profissional.status,
      "idestabelecimento": profissional.idEstabelecimento
    };

    //await db .collection("profissional") .doc(uidProfissional) .update(profissionalJson);
    await supabase
        .from("profissionais")
        .update(profissionalJson)
        .eq("id", uidProfissional);
    atualizarDiasDaSemanaProfissional(
        diasdaSemana: profissional.diasTrabalho,
        idProfisssional: uidProfissional);
  }

  Future<void> updateTokenProfissional(
      {int? token, required int uidProfissional}) async {
    var profissionalJson = {
      "token": token,
    };

    //await db .collection("profissional") .doc(uidProfissional) .update(profissionalJson);
    await supabase
        .from("profissionais")
        .update(profissionalJson)
        .eq("id", uidProfissional);
  }

  Future<Map<String, dynamic>> verificarTokenProfissional(
      {required int token, required String email}) async {
    //await db .collection("profissional") .doc(uidProfissional) .update(profissionalJson);
    Map<String, dynamic> jsonResult = {
      "id": null,
      "verificadoToken": false,
    };
    var result = await supabase
        .from("profissionais")
        .select()
        .eq("email", email)
        .eq("token", token);
    if (result.isNotEmpty) {
      jsonResult = {
        "verificadoToken": true,
        "id": result[0]['id'],
      };
      return jsonResult;
    }
    return jsonResult;
  }

  Future<void> atulizarSenhaProfissional(
      {required String senha,
      required int uidProfissional,
      required int idEstabelecimento,
      required String email}) async {
    final String key = XorCipher().getSecretKey(20);

    final encrypted = XorCipher().encryptData(senha, key);
    var profissionalJson = {"senha": encrypted, "token": null, 'keyhash': key};

    //await db .collection("profissional") .doc(uidProfissional) .update(profissionalJson);
    await supabase
        .from("profissionais")
        .update(profissionalJson)
        .eq("id", uidProfissional)
        .eq("email", email)
        .eq("idestabelecimento", idEstabelecimento);
  }

  Future<void> atualizarDiasDaSemanaProfissional(
      {required int idProfisssional,
      required List<Map<String, dynamic>> diasdaSemana}) async {
    deletarTodosDiasDaSemanaProfissional(idProfisssional: idProfisssional);
    for (var diaJson in diasdaSemana) {
      diaJson["profissional_id"] = idProfisssional;
    }
    await supabase.from("profissional_dias").insert(diasdaSemana);
  }

  Future<void> deletarTodosDiasDaSemanaProfissional(
      {required int idProfisssional}) async {
    await supabase
        .from("profissional_dias")
        .delete()
        .eq("profissional_id", idProfisssional);
  }

  Future<void> deleteProfissionalRepository(
      {required int uidProfissional}) async {
    // await db.collection("profissional").doc(uidProfissional).delete();

    await supabase.from("profissionais").delete().eq("id", uidProfissional);
  }

  Future<void> updateStatusProfissionalRepository(
      {required Profissional profissional,
      required int uidProfissional}) async {
    var profissionalJson = {
      "status": profissional.status,
    };
    await supabase
        .from("profissionais")
        .update(profissionalJson)
        .eq("id", uidProfissional);

    //await db .collection("profissional").doc(uidProfissional) .update(profissional_json);
  }

  Future<void> atualizarHorariosProfissional(
      {required int idProfisssional,
      required Profissional profissional}) async {
    deletarHorariosProfissional(idProfisssional: idProfisssional);
    List<Map<String, dynamic>> horariosAtivados = [];
    for (var horario in profissional.horariosTrabalho) {
      if (horario["ativado"] == true) {
        horario["id_profissional"] = idProfisssional;
        horariosAtivados.add(horario);
      }
    }
    if (horariosAtivados.isNotEmpty) {
      await supabase.from("profissional_horarios").insert(horariosAtivados);
    }
  }

  Future<void> deletarHorariosProfissional(
      {required int idProfisssional}) async {
    await supabase
        .from("profissional_horarios")
        .delete()
        .eq("id_profissional", idProfisssional);
  }

  void updateDiasTrabalhoProfissionalRepository(
      {required Profissional profissional,
      required int uidProfissional}) async {
    var profissional_json = {
      "diastrabalho": profissional.diasTrabalho,
    };
    /*
    await db
        .collection("profissional")
        .doc(uidProfissional)
        .update(profissional_json);
    */
    await supabase
        .from("profissionais")
        .update(profissional_json)
        .eq("id", uidProfissional);
  }

  //Horarios Metodos
  Future<void> criarHorarios() async {
    final List<Map<String, dynamic>> jsonHorario = [];
    int hora = 5;
    int minuto = 0;

    while (hora < 21 || (hora == 21 && minuto == 0)) {
      final horaFormatada =
          '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
      jsonHorario.add({"hora": horaFormatada});

      minuto += 30;
      if (minuto >= 60) {
        minuto = 0;
        hora++;
      }
    }

    await supabase.from("horarios_trabalho").insert(jsonHorario);
  }

  //Fim horarios Metodos
}
