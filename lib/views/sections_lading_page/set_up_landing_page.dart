import 'package:agendamento_barber/models/Estabelecimento.dart';
import 'package:agendamento_barber/models/Profissional.dart';
import 'package:agendamento_barber/repository/estabelecimentoRepository.dart';
import 'package:agendamento_barber/repository/profissionalRepository.dart';
import 'package:agendamento_barber/utils/WidgetsDesign.dart';
import 'package:agendamento_barber/views/lading_page.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xor_encryption/xor_encryption.dart';

class SetUpLandingPage extends StatefulWidget {
  const SetUpLandingPage({super.key});

  @override
  State<SetUpLandingPage> createState() => _SetUpLandingPageState();
}

class _SetUpLandingPageState extends State<SetUpLandingPage> {
  Widgetsdesign widgetsdesign = Widgetsdesign();

  TextEditingController apiBaseUrlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();
  TextEditingController apiKeyServiceController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController razaoSocialController = TextEditingController();
  TextEditingController cnpjController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController enderecoController = TextEditingController();
  TextEditingController complementoController = TextEditingController();
  TextEditingController cepController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController sobreNosController = TextEditingController();
  TextEditingController horarioAtendimentoController = TextEditingController();
  final keyForm = GlobalKey<FormState>();
  String fileNameSobreNos = "Nenhuma imagem Selecionada";
  String fileNameLogo = "Nenhuma imagem Selecionada";
  String logoUrl = "";
  String fotoPerfilUrl = "";
  String sobreNosImgUrl = "";
  bool setUpStatus = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verificarStatusSetUp();
  }

  void verificarStatusSetUp() async {
    bool status = await Estabelecimentorepository().setUpStatus();
    setState(() {
      setUpStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    double widthMedia = MediaQuery.of(context).size.width;
    double HeightMedia = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: HeightMedia,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
            "asset/fundotop2.png",
          ),
          fit: BoxFit.cover,
        )),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Card(
                  elevation: 7,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: ResponsiveBreakpoints.of(context).largerThan(MOBILE)
                        ? widthMedia * 0.5
                        : widthMedia * 0.85,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade700)),
                    child: Form(
                      key: keyForm,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (setUpStatus == false) ...[
                            Center(
                              child: Text(
                                "Configurações Iniciais\nAgenda Corte",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.robotoCondensed(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color:
                                        const Color.fromARGB(232, 161, 46, 0)),
                              ),
                            ),

                            //Configurações Loja
                            Text(
                              "Configuração Barbearia",
                              style: GoogleFonts.robotoCondensed(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nome",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildLabel(
                                          hintText: "",
                                          controller: nomeController),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Razão Social",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildLabel(
                                          hintText: "",
                                          controller: razaoSocialController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Logo",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .largerThan(MOBILE)
                                  ? widthMedia * 0.5
                                  : widthMedia * 0.85,
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform
                                                .pickFiles();

                                        if (result != null) {
                                          Uint8List? fileBytesResult =
                                              result.files.first.bytes;
                                          String fileName =
                                              result.files.first.name;

                                          String path =
                                              "${DateTime.now().millisecondsSinceEpoch.toString()}.png";
                                          final supabase =
                                              Supabase.instance.client;
                                          await supabase.storage
                                              .from('imagens')
                                              .uploadBinary(
                                                path,
                                                fileBytesResult!,
                                                fileOptions: const FileOptions(
                                                    cacheControl: '3600',
                                                    upsert: false),
                                              );
                                          String imagePublicUrl = await supabase
                                              .storage
                                              .from("imagens")
                                              .getPublicUrl(path);
                                          String pathFotoPerfil =
                                              "${DateTime.now().millisecondsSinceEpoch.toString()}.png";
                                          await supabase.storage
                                              .from('imagens')
                                              .uploadBinary(
                                                pathFotoPerfil,
                                                fileBytesResult!,
                                                fileOptions: const FileOptions(
                                                    cacheControl: '3600',
                                                    upsert: false),
                                              );
                                          String fotoPerfilPublicUrl =
                                              await supabase.storage
                                                  .from("imagens")
                                                  .getPublicUrl(pathFotoPerfil);
                                          setState(() {
                                            fileNameLogo = fileName;
                                            logoUrl = imagePublicUrl;
                                            fotoPerfilUrl = fotoPerfilPublicUrl;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.image),
                                      label: Text("Escolher Imagem")),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    fileNameLogo,
                                    style: GoogleFonts.roboto(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CNPJ",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildCNPJ(
                                          hintText: "",
                                          inputFormatter: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            CnpjInputFormatter()
                                          ],
                                          controller: cnpjController),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Telefone",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildTelefone(
                                          hintText: "",
                                          inputFormatter: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            TelefoneInputFormatter(),
                                          ],
                                          controller: telefoneController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),

                            Text(
                              "Endereço",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            widgetsdesign.textFildLabel(
                                hintText: "", controller: enderecoController),

                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Complemento",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildLabel(
                                          hintText: "",
                                          controller: complementoController),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CEP",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildCep(
                                          hintText: "",
                                          inputFormatter: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            CepInputFormatter(ponto: false),
                                          ],
                                          controller: cepController),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildLabel(
                                          hintText: "",
                                          controller: emailController),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Senha Acesso",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      widgetsdesign.textFildLabel(
                                          hintText: "",
                                          controller: senhaController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //Configurações Landing Page
                            Text(
                              "Configuração Landing Page",
                              style: GoogleFonts.robotoCondensed(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Sobre Nós",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            widgetsdesign.textFildTextArea(
                                hintText: "",
                                maxLines: 4,
                                controller: sobreNosController),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Imagem Seção Sobre Nós",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .largerThan(MOBILE)
                                  ? widthMedia * 0.5
                                  : widthMedia * 0.85,
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform
                                                .pickFiles();

                                        if (result != null) {
                                          Uint8List? fileBytesResult =
                                              result.files.first.bytes;
                                          String fileName =
                                              result.files.first.name;

                                          String path =
                                              "${DateTime.now().millisecondsSinceEpoch.toString()}.png";
                                          final supabase =
                                              Supabase.instance.client;
                                          await supabase.storage
                                              .from('imagens')
                                              .uploadBinary(
                                                path,
                                                fileBytesResult!,
                                                fileOptions: const FileOptions(
                                                    cacheControl: '3600',
                                                    upsert: false),
                                              );
                                          String imagePublicUrl = await supabase
                                              .storage
                                              .from("imagens")
                                              .getPublicUrl(path);

                                          setState(() {
                                            fileNameSobreNos = fileName;
                                            sobreNosImgUrl = imagePublicUrl;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.image),
                                      label: Text("Escolher Imagem")),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    fileNameSobreNos,
                                    style: GoogleFonts.roboto(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Horário de Atendimento",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            widgetsdesign.textFildTextArea(
                                hintText: "",
                                maxLines: 4,
                                controller: horarioAtendimentoController),
                            SizedBox(
                              height: 5,
                            ),
                            //Botão Salvar Configurações
                            Center(
                                child: ElevatedButton.icon(
                                    onPressed: () async {
                                      EasyLoading.show(
                                          status:
                                              "Carregando...\nPor favor Aguarde");
                                      if (fileNameLogo ==
                                          "Nenhuma imagem Selecionada") {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Selecionar imagem logo")));
                                      }
                                      if (fileNameSobreNos ==
                                          "Nenhuma imagem Selecionada") {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Selecionar imagem seção Sobre Nós")));
                                      }
                                      if (!keyForm.currentState!.validate()) {
                                        EasyLoading.dismiss();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Verifique o formulario")));
                                      } else {
                                        Estabelecimento estabelecimento =
                                            Estabelecimento(
                                          nome: nomeController.text,
                                          telefone:
                                              UtilBrasilFields.obterTelefone(
                                                  telefoneController.text,
                                                  ddd: true,
                                                  mascara: false),
                                          telefoneWhatsapp:
                                              UtilBrasilFields.obterTelefone(
                                                  telefoneController.text,
                                                  ddd: true,
                                                  mascara: false),
                                          cep: cepController.text,
                                          endereco: enderecoController.text,
                                          complemento:
                                              complementoController.text,
                                          urlLogo: logoUrl,
                                          cnpj: cnpjController.text,
                                          email: emailController.text,
                                          horarioFuncionamento:
                                              horarioAtendimentoController.text,
                                          razaoSocial:
                                              razaoSocialController.text,
                                          setUp: true,
                                          sobreNos: sobreNosController.text,
                                          sobreNosImg: sobreNosImgUrl,
                                        );

                                        await Estabelecimentorepository()
                                            .createEstabelecimentoRepositorySetUP(
                                                estabelecimento:
                                                    estabelecimento,
                                                senha: senhaController.text);
                                        int idEstabelecimento =
                                            await Estabelecimentorepository()
                                                .getIdEstabelecimento();
                                        Profissional profissional =
                                            Profissional(
                                                nome: nomeController.text,
                                                email: emailController.text,
                                                telefone: UtilBrasilFields
                                                    .obterTelefone(
                                                        telefoneController.text,
                                                        ddd: true,
                                                        mascara: false),
                                                telefoneWhatsapp:
                                                    UtilBrasilFields
                                                        .obterTelefone(
                                                            telefoneController
                                                                .text,
                                                            ddd: true,
                                                            mascara: false),
                                                fotoPerfil: fotoPerfilUrl,
                                                horariosTrabalho: [],
                                                diasTrabalho: [],
                                                perfil: "admin",
                                                status: true,
                                                idEstabelecimento:
                                                    idEstabelecimento);

                                        Profissionalrepository()
                                            .createProfissionalRepository(
                                                profissional: profissional,
                                                senha: senhaController.text);

                                        EasyLoading.dismiss();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LadingPage(),
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.save),
                                    label: Text("Salva Configuração"))),
                            SizedBox(
                              height: 10,
                            ),
                          ] else ...[
                            Center(
                              child: Text(
                                "Configurações Iniciais\njá realizadas",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.robotoCondensed(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                "Acessar como administrador ou\nEntre em contato com Administrador do Sistema.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.robotoCondensed(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color:
                                        const Color.fromARGB(232, 161, 46, 0)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
