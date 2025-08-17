import 'package:agendamento_barber/models/Estabelecimento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Estabelecimentorepository {
  var db = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  Future<void> createEstabelecimentoRepositorySetUP(
      {required Estabelecimento estabelecimento, required String senha}) async {
    var estabelecimentoJson = {
      "nome": estabelecimento.nome,
      "telefone": estabelecimento.telefone,
      "telefonewhatsapp": estabelecimento.telefoneWhatsapp,
      "endereco": estabelecimento.endereco,
      "complemento": estabelecimento.complemento,
      "cep": estabelecimento.cep,
      "urllogo": estabelecimento.urlLogo,
      "cnpj": estabelecimento.cnpj ?? "",
      "email": estabelecimento.email,
      "sobre_nos": estabelecimento.sobreNos,
      "sobre_nos_img": estabelecimento.sobreNosImg,
      "horario_funcionamento": estabelecimento.horarioFuncionamento,
      "razao_social": estabelecimento.razaoSocial,
      "set_up": estabelecimento.setUp,
    };
    //await db.collection("estabelecimento").add(estabelecimentoJson);
    await supabase.from("estabelecimento").insert(estabelecimentoJson);
  }

  Future<Estabelecimento> getEstabelecimentoRepository() async {
    // var documentos = await db.collection("estabelecimento").get();
    var documentos = await supabase.from('estabelecimento').select();

    Estabelecimento estabelecimento = Estabelecimento(
      uid: documentos.first["id"],
      nome: documentos.first["nome"],
      telefone: documentos.first["telefone"],
      telefoneWhatsapp: documentos.first["telefonewhatsapp"],
      cep: documentos.first["cep"],
      endereco: documentos.first["endereco"],
      complemento: documentos.first["complemento"],
      urlLogo: documentos.first["urllogo"],
      cnpj: documentos.first["cnpj"],
      email: documentos.first["email"],
      horarioFuncionamento: documentos.first["horario_funcionamento"],
      razaoSocial: documentos.first["razao_social"],
      setUp: documentos.first["set_up"],
      sobreNos: documentos.first["sobre_nos"],
      sobreNosImg: documentos.first["sobre_nos_img"],
    );

    return estabelecimento;
  }

  Future<int> getIdEstabelecimento() async {
    // var documentos = await db.collection("estabelecimento").get();
    var documentos = await supabase.from('estabelecimento').select('id');

    int estabelecimentoId = documentos.first["id"];

    return estabelecimentoId;
  }

  Future<bool> setUpStatus() async {
    // var documentos = await db.collection("estabelecimento").get();
    var documentos = await supabase.from('estabelecimento').select('set_up');

    if (documentos.isNotEmpty && documentos.first["set_up"] == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateEstabelecimentoRepository(
      {required Estabelecimento estabelecimento,
      required int uidEstabelecimento}) async {
    var estabelecimentoJson = {
      "nome": estabelecimento.nome,
      "telefone": estabelecimento.telefone,
      "telefonewhatsapp": estabelecimento.telefoneWhatsapp,
      "endereco": estabelecimento.endereco,
      "complemento": estabelecimento.complemento,
      "cep": estabelecimento.cep,
      "urllogo": estabelecimento.urlLogo,
      "cnpj": estabelecimento.cnpj,
      "razao_social": estabelecimento.razaoSocial,
      "sobre_nos": estabelecimento.sobreNos,
      "sobre_nos_img": estabelecimento.sobreNosImg,
      "horario_funcionamento": estabelecimento.horarioFuncionamento,
    };
    await supabase
        .from('estabelecimento')
        .update(estabelecimentoJson)
        .eq("id", uidEstabelecimento);
    //await db .collection("estabelecimento") .doc(uidEstabelecimento)  .update(estabelecimentoJson);
  }

  Future<void> deleteEstabelecimentoRepository(
      {required int uidEstabelecimento}) async {
    await supabase
        .from('estabelecimento')
        .delete()
        .eq("id", uidEstabelecimento);
    // await db.collection("estabelecimento").doc(uidEstabelecimento).delete();
  }
}
