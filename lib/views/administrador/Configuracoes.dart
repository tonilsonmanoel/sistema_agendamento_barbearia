import 'package:agendamento_barber/models/Estabelecimento.dart';
import 'package:agendamento_barber/repository/estabelecimentoRepository.dart';
import 'package:agendamento_barber/repository/storage_service.dart';
import 'package:agendamento_barber/utils/WidgetsDesign.dart';
import 'package:agendamento_barber/views/administrador/login_administrador.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key, required this.estabelecimento});
  final Estabelecimento estabelecimento;
  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  Widgetsdesign widgetsdesign = Widgetsdesign();
  final keyForm = GlobalKey<FormState>();
  Uint8List? imgMemoryPicked;
  Uint8List? imgMemorySobreNos;

  TextEditingController nomeController = TextEditingController();
  TextEditingController telefoneControler = TextEditingController();
  TextEditingController enderecoControler = TextEditingController();
  TextEditingController complementoController = TextEditingController();
  TextEditingController cepControler = TextEditingController();
  TextEditingController razaoSocialController = TextEditingController();
  TextEditingController cnpjController = TextEditingController();
  TextEditingController sobreNosController = TextEditingController();
  TextEditingController horarioAtendimentoController = TextEditingController();
  String urlLogo = "";
  String fileNameSobreNos = "Nenhuma imagem Selecionada";
  String sobreNosImgUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nomeController.text = widget.estabelecimento.nome;
    razaoSocialController.text = widget.estabelecimento.razaoSocial ?? "";
    cnpjController.text = widget.estabelecimento.cnpj ?? "";
    telefoneControler.text = UtilBrasilFields.obterTelefone(
        widget.estabelecimento.telefone,
        ddd: true,
        mascara: true);

    enderecoControler.text = widget.estabelecimento.endereco;
    complementoController.text = widget.estabelecimento.complemento;
    cepControler.text = widget.estabelecimento.cep;
    urlLogo = widget.estabelecimento.urlLogo;
    sobreNosImgUrl = widget.estabelecimento.sobreNosImg ?? "";
    sobreNosController.text = widget.estabelecimento.sobreNos ?? "";
    horarioAtendimentoController.text =
        widget.estabelecimento.horarioFuncionamento ?? "";
    fileNameSobreNos = StorageService()
        .getPathUrl(publicUrl: widget.estabelecimento.sobreNosImg!);
  }

  @override
  Widget build(BuildContext context) {
    double widthMedia = MediaQuery.of(context).size.width;

    Widget formularioAgendamento() {
      return Column(
        children: [
          Form(
            key: keyForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nome Empresa",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          widgetsdesign.textFildLabel(
                              hintText: "Informe seu nome empresa",
                              controller: nomeController),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Razão Social",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          widgetsdesign.textFildLabel(
                              hintText: "Informe seu nome empresa",
                              controller: razaoSocialController),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CNPJ",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          widgetsdesign.textFildCNPJ(
                              hintText: "",
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly,
                                CnpjInputFormatter()
                              ],
                              controller: cnpjController),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Telefone com DDD",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          widgetsdesign.textFildTelefone(
                              hintText: "Informa seu telefone",
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly,
                                TelefoneInputFormatter(),
                              ],
                              controller: telefoneControler),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Endereço",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                widgetsdesign.textFildLabel(
                    hintText: "Informa seu endereço",
                    controller: enderecoControler),
                SizedBox(
                  height: 10,
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Complemento",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          widgetsdesign.textFildLabel(
                              hintText: "Informa o complemento",
                              controller: complementoController),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CEP",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          widgetsdesign.textFildCep(
                              hintText: "Informa o CEP",
                              textInputType: TextInputType.number,
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly,
                                CepInputFormatter(ponto: false),
                              ],
                              controller: cepControler),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Configuração Landing Page",
                  style: GoogleFonts.robotoCondensed(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Sobre Nós",
                  style: GoogleFonts.roboto(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                widgetsdesign.textFildTextArea(
                    hintText: "", maxLines: 4, controller: sobreNosController),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Imagem Seção Sobre Nós",
                  style: GoogleFonts.roboto(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: ResponsiveBreakpoints.of(context).largerThan(MOBILE)
                      ? widthMedia * 0.5
                      : widthMedia * 0.85,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ["jpg", "png"]);

                            if (result != null) {
                              String fileName = result.files.first.name;
                              setState(() {
                                imgMemorySobreNos = result.files.first.bytes;
                                fileNameSobreNos = fileName;
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
                        style: GoogleFonts.roboto(color: Colors.white),
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
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                widgetsdesign.textFildTextArea(
                    hintText: "",
                    maxLines: 4,
                    controller: horarioAtendimentoController),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
          Container(),
        ],
      );
    }

    Widget buttonSalvar() {
      return ElevatedButton.icon(
          onPressed: () async {
            EasyLoading.show(
              status: "Carregando...",
              dismissOnTap: false,
            );

            //upload img
            String logoUploadurl = urlLogo;
            if (imgMemoryPicked != null) {
              await StorageService()
                  .uploadReplaceImgStorage(
                      imgMemory: imgMemoryPicked!,
                      publicUrl: widget.estabelecimento.urlLogo)
                  .then(
                (value) {
                  logoUploadurl = value!;
                },
              );
            }
            String imagePublicUrl = widget.estabelecimento.sobreNosImg!;
            if (imgMemorySobreNos != null) {
              await StorageService()
                  .uploadReplaceImgStorage(
                      imgMemory: imgMemorySobreNos!,
                      publicUrl: widget.estabelecimento.sobreNosImg!)
                  .then(
                (value) {
                  imagePublicUrl = value!;
                },
              );
            }

            //
            Estabelecimento estabelecimento = Estabelecimento(
              uid: widget.estabelecimento.uid,
              nome: nomeController.text,
              cnpj: cnpjController.text,
              urlLogo: logoUploadurl,
              horarioFuncionamento: horarioAtendimentoController.text,
              razaoSocial: razaoSocialController.text,
              sobreNos: sobreNosController.text,
              sobreNosImg: imagePublicUrl,
              telefone: UtilBrasilFields.obterTelefone(telefoneControler.text,
                  ddd: true, mascara: false),
              telefoneWhatsapp: UtilBrasilFields.obterTelefone(
                  widget.estabelecimento.telefoneWhatsapp,
                  ddd: true,
                  mascara: false),
              cep: cepControler.text,
              endereco: enderecoControler.text,
              complemento: complementoController.text,
            );

            Estabelecimentorepository()
                .updateEstabelecimentoRepository(
                    estabelecimento: estabelecimento,
                    uidEstabelecimento: estabelecimento.uid!)
                .then((value) {
              EasyLoading.dismiss();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginAdministrador(),
                  ));
            });

            // confirmação feita pelo barbeiro
          },
          style: ButtonStyle(
              elevation: WidgetStatePropertyAll(4),
              alignment: Alignment.center,
              overlayColor:
                  WidgetStatePropertyAll(Color.fromARGB(255, 18, 18, 18)),
              surfaceTintColor:
                  WidgetStatePropertyAll(Color.fromARGB(255, 46, 46, 46)),
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
              shadowColor:
                  WidgetStatePropertyAll(const Color.fromARGB(255, 0, 0, 0)),
              backgroundColor:
                  WidgetStatePropertyAll(Color.fromARGB(255, 46, 46, 46))),
          icon: Icon(
            FontAwesomeIcons.save,
            size: 27,
            color: widgetsdesign.amareloColor,
          ),
          label: Text(
            "Salvar",
            style: GoogleFonts.robotoCondensed(
                color: widgetsdesign.amareloColor,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ));
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 19, 19, 19),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widthMedia * 0.04),
          child: Column(
            children: [
              widgetsdesign.cabecalhoConfiguracoes(
                label: "Configurações",
                botaoWidget: Container(),
                sizeLabel: 22,
                searchCalender: false,
                colorLabel: widgetsdesign.amareloColor,
                fontWeight: FontWeight.w700,
                context: context,
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: 200,
                        width: 220,
                        child: imgMemoryPicked != null
                            ? Image.memory(
                                imgMemoryPicked!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                urlLogo,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 10,
                      child: IconButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ["jpg", "png"]);

                          if (result != null) {
                            setState(() {
                              imgMemoryPicked = result.files.first.bytes;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white54)),
                      ),
                    )
                  ],
                ),
              ),
              formularioAgendamento(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widgetsdesign.buttonIcon(
                      icon: Container(),
                      label: "Voltar",
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  buttonSalvar(),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
