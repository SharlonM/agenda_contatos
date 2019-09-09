import 'dart:io';

import 'package:agenda_contatos/model/Contato.dart';
import 'package:agenda_contatos/model/contato_banco.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'novoContato.dart';

enum OrderOptions { az, za }

class Home_Page extends StatefulWidget {
  Color corPadrao = Color.fromRGBO(220, 20, 60, 1);

  @override
  _Home_PageState createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  ContatoBanco banco = ContatoBanco();
  List<Contato> contatos = List();
  bool _excluir = false;

  @override
  void initState() {
    _atualizarContatos();
  }

  appbar() {
    return AppBar(
      backgroundColor: widget.corPadrao,
      title: Text("Contatos"),
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton<OrderOptions>(
          itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem(
              child: Text("Ordenar de A-Z"),
              value: OrderOptions.az,
            ),
            const PopupMenuItem(
              child: Text("Ordenar de Z-A"),
              value: OrderOptions.za,
            )
          ],
          onSelected: _ordemList,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showViewContato();
        },
        child: Icon(Icons.add),
        backgroundColor: widget.corPadrao,
      ),
      body: listViewDeContatos(),
    );
  }

  listViewDeContatos() {
    return ListView.builder(
      itemCount: contatos.length,
      itemBuilder: (context, index) {
        return _cardContato(context, index);
      },
      padding: EdgeInsets.all(10),
    );
  }

  imagemContato(index) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: contatos[index].img != null
                ? FileImage(File(contatos[index].img))
                : AssetImage("images/person-male.png"),
            fit: BoxFit.cover),
      ),
    );
  }

  informacoesContato(index) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(contatos[index].name ?? "",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(contatos[index].email ?? "", style: TextStyle(fontSize: 20)),
          Text(contatos[index].phone ?? "", style: TextStyle(fontSize: 20))
        ],
      ),
    );
  }

  _cardContato(context, index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[imagemContato(index), informacoesContato(index)],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  Future _showViewContato({Contato contato}) async {
    final recContato = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewNovoContato(
                  contato: contato,
                )));

    if (recContato != null) {
      if (contato != null) {
        await banco.atualizarContato(recContato);
      } else {
        await banco.salvarConato(recContato);
      }
      _atualizarContatos();
    } else {}
  }

  void _atualizarContatos() {
    banco.getTodosContatos().then((list) {
      setState(() {
        contatos = list;
      });
    });
  }

  criarBotao(index, texto, onPress()) {
    return FlatButton(
        child: Text(
          texto,
          style: TextStyle(color: Colors.pink, fontSize: 18),
        ),
        onPressed: onPress);
  }

  containerOptions(index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        criarBotao(index, "Ligar", () {
          launch("tel:${contatos[index].phone}");
          Navigator.pop(context);
        }),
        Divider(height: 3),
        criarBotao(index, "Editar", () {
          Navigator.pop(context);
          _showViewContato(contato: contatos[index]);
        }),
        Divider(height: 3),
        criarBotao(index, "Excluir", () async {
          await _confirmarExclusao();
          if (_excluir) {
            banco.deletarConato(contatos[index].id);
            setState(() {
              contatos.removeAt(index);
              Navigator.pop(context);
            });
          }
        }),
      ],
    );
  }

  void _showOptions(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                  padding: EdgeInsets.all(10), child: containerOptions(index));
            },
          );
        });
  }

  _confirmarExclusao() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Tem certeza que deseja excluir esse contato ?"),
            content: Text("Ao excluir todas as informações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  _excluir = false;
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: () {
                  Navigator.pop(context);
                  _excluir = true;
                },
              )
            ],
          );
        });
  }

  morePressed() {
    return 0;
  }

  void _ordemList(OrderOptions result) {
    switch (result) {
      case OrderOptions.az:
        contatos.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.za:
        contatos.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
