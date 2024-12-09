// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_agenda/db_helper.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
   final TextEditingController _emailController = TextEditingController();
  
 
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addData() async {
    
    if (_nomeController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todos os campos são obrigatórios!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; 
    }

  // Validação do e-mail
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, insira um e-mail válido!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    await SQLHelper.createData(
        _nomeController.text, _telefoneController.text, _emailController.text);
    _refreshData(); 
  }

  Future<void> _updateData(int id) async {
    
    if (_nomeController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todos os campos são obrigatórios!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; 
    }

     if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, insira um e-mail válido!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    
    await SQLHelper.updateData(id, _nomeController.text,
        _telefoneController.text, _emailController.text);
    _refreshData(); 
  }

  void _deleteData(int id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Você tem certeza de que deseja excluir este item?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () async {
              await SQLHelper.deleteData(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text("Deletado com Sucesso"),
              ));
              _refreshData();
            },
            child: Text('Sim'),
          ),
        ],
      ),
    );
  }

  

   

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _nomeController.text = existingData['nome'];
      _telefoneController.text = existingData['telefone'];
      _emailController.text = existingData['email'];
    } else {
      // Adição: Limpar os controladores
      _nomeController.clear();
      _telefoneController.clear();
      _emailController.clear();
    }

    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 30,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nome',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _telefoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Telefone',
                    ),
                    keyboardType: TextInputType.phone, 
                    inputFormatters: [_telefoneMask], 
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'E-mail',
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addData();
                        }
                        if (id != null) {
                          await _updateData(id);
                        }
                        _nomeController.text = "";
                        _telefoneController.text = "";
                        _emailController.text = "";

                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          id == null ? "Criar" : "Atualizar",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 207, 209, 209),
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text(
          "Agenda CRUD",
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 253, 251),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 250, 96, 0),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _allData[index]['nome'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.grey, size: 16),
                              SizedBox(width: 8),
                              Text(
                                _allData[index]['telefone'],
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.grey, size: 16),
                              SizedBox(width: 8),
                              Text(
                                _allData[index]['email'],
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                showBottomSheet(_allData[index]['id']);
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.indigo,
                              )),
                          IconButton(
                              onPressed: () {
                                _deleteData(_allData[index]['id']);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ),
                  )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
