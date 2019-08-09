import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Contato.dart';

final String nomeTabela = "tableContatos";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContatoBanco {
  static final ContatoBanco _instance = ContatoBanco.internal();

  factory ContatoBanco() => _instance;

  ContatoBanco.internal();

  Database _banco;

  Future<Database> get banco async {
    if (_banco != null) {
      return _banco;
    } else {
      _banco = await initBanco();
      return _banco;
    }
  }

  Future<Database> initBanco() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contatos.banco");
    return await openDatabase(path, version: 1,
        onCreate: (Database banco, int newerVersion) async {
      await banco.execute("CREATE TABLE $nomeTabela("
          "$idColumn INTEGER PRIMARY KEY,"
          " $nameColumn TEXT,"
          " $emailColumn TEXT,"
          "$phoneColumn TEXT, "
          "$imgColumn TEXT)");
    });
  }

  Future<Contato> salvarConato(Contato contato) async {
    Database bancoContato = await banco;
    contato.id = await bancoContato.insert(nomeTabela, contato.toMap());
    return contato;
  }

  Future<Contato> getContato(int id) async {
    Database bancoContato = await banco;
    List<Map> maps = await bancoContato.query(nomeTabela,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = $id");

    if (maps.isNotEmpty) {
      return Contato.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletarConato(int id) async {
    Database bancoContato = await banco;
    return await bancoContato.delete(nomeTabela, where: "$idColumn = $id");
  }

  Future<int> atualizarContato(Contato contato) async {
    Database bancoContato = await banco;
    return await bancoContato.update(nomeTabela, contato.toMap(),
        where: "$idColumn = ?", whereArgs: [contato.id]);
  }

  Future<List> getTodosContatos() async {
    Database bancoContato = await banco;
    List listMap = await bancoContato.rawQuery("SELECT * FROM $nomeTabela");
    List<Contato> listContato = List();
    for (Map m in listMap) {
      listContato.add(Contato.fromMap(m));
    }
    return listContato;
  }

  Future<int> getNumber() async {
    Database bancoContato = await banco;
    return Sqflite.firstIntValue(
        await bancoContato.rawQuery("SELECT COUNT(*) FROM $nomeTabela"));
  }

  closeBanco() async {
    Database bancoContato = await banco;
    await bancoContato.close();
  }
}
