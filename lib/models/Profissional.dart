class Profissional {
  String nome;
  int? uid;
  String email;
  String telefone;
  String telefoneWhatsapp;
  String fotoPerfil;
  List<Map<String, dynamic>> horariosTrabalho;
  List<Map<String, dynamic>> diasTrabalho;
  bool status;
  int? idEstabelecimento;
  String perfil;
  int? token;
  String? keyhash;
  Profissional(
      {required this.nome,
      required this.email,
      this.uid,
      this.token,
      this.keyhash,
      required this.telefone,
      required this.telefoneWhatsapp,
      required this.fotoPerfil,
      required this.horariosTrabalho,
      required this.diasTrabalho,
      this.idEstabelecimento,
      required this.perfil,
      required this.status});
}
