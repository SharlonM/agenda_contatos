import 'dart:io';

import 'package:agenda_contatos/model/Contato.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';

class ViewNovoContato extends StatefulWidget {
  final Contato contato;

  ViewNovoContato({this.contato});

  @override
  _ViewNovoContatoState createState() => _ViewNovoContatoState();
}

class _ViewNovoContatoState extends State<ViewNovoContato> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  Contato _editContato;
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Home_Page().corPadrao,
          title: Text(_editContato.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formkey.currentState.validate()) {
              Navigator.pop(context, _editContato);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.pink,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: imagemContato(),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.gallery)
                        .then((file) {
                      if (file == null) return;
                      setState(() {
                        _editContato.img = file.path;
                      });
                    });
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: "Nome", fillColor: Colors.black),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value.isEmpty || value == null) {
                      return "Campo Obrigatorio";
                    } else {
                      _editContato.name = value;
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: "Email", fillColor: Colors.black),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Campo Obrigatorio";
                    } else {
                      _editContato.email = value;
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      labelText: "Phone", fillColor: Colors.black),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Campo Obrigatorio";
                    } else {
                      _editContato.phone = value;
                      return null;
                    }
                  },
                  keyboardType: TextInputType.numberWithOptions(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  imagemContato() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: _editContato.img != null
                ? FileImage(File(_editContato.img))
                : AssetImage("images/person-male.png")),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (widget.contato == null) {
      Navigator.pop(context);
      return Future.value(false);
    } else {
      if (_nameController.text != widget.contato.name ||
          _phoneController.text != widget.contato.phone ||
          _emailController.text != widget.contato.email) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Descartar alterações ?"),
                content: Text("Ao voltar as alterações serão perdidas."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text("Sim"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
        return Future.value(false);
      } else {
        return Future.value(true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.contato == null) {
      _editContato = Contato();
    } else {
      _editContato = Contato.fromMap(widget.contato.toMap());
      _nameController.text = _editContato.name;
      _emailController.text = _editContato.email;
      _phoneController.text = _editContato.phone;
    }
  }
}
