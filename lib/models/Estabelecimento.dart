class Estabelecimento {
  int? uid;
  String nome;
  String telefone;
  String telefoneWhatsapp;
  String endereco;
  String complemento;
  String cep;
  String urlLogo;
  String? cnpj;
  String? email;
  String? sobreNos;
  String? sobreNosImg;
  String? horarioFuncionamento;
  String? razaoSocial;
  bool? setUp;

  Estabelecimento({
    required this.nome,
    required this.telefone,
    required this.telefoneWhatsapp,
    required this.cep,
    required this.endereco,
    required this.complemento,
    required this.urlLogo,
    this.uid,
    this.cnpj,
    this.email,
    this.horarioFuncionamento,
    this.razaoSocial,
    this.setUp,
    this.sobreNos,
    this.sobreNosImg,
  });
  Estabelecimento.vazio({
    this.nome = "",
    this.telefone = "",
    this.telefoneWhatsapp = "",
    this.cep = "",
    this.endereco = "",
    this.complemento = "",
    this.urlLogo = "",
    this.cnpj = "",
    this.email = "",
    this.horarioFuncionamento = "",
    this.razaoSocial = "",
    this.sobreNos = "",
    this.sobreNosImg = "",
  });
}
