import 'dart:io';

import 'package:agenda_contatos/model/Contato.dart';
import 'package:agenda_contatos/model/contato_banco.dart';
import 'package:flutter/material.dart';

class Home_Page extends StatefulWidget {
  @override
  _Home_PageState createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  ContatoBanco banco = ContatoBanco();
  List<Contato> contatos = List();

  @override
  void initState() {
    banco.getTodosContatos().then((list) {
      setState(() {
        contatos = list;
      });
    });
  }

  appbar() {
    return AppBar(
      backgroundColor: Color.fromRGBO(220, 20, 60, 1),
      title: Text("Contatos"),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: null)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(220, 20, 60, 1),
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
                : AssetImage("images/person-male.png")),
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
            children: <Widget>[
              imagemContato(index),
              informacoesContato(index)
            ],
          ),
        ),
      ),
    );
  }
}
