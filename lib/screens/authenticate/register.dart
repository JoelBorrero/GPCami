import 'authentication.dart';
import 'package:flutter/material.dart';
import 'package:grupospequenos/services/auth.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/database.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

final PageController _controller = PageController();
void goToPage(int page) {
  _controller.animateToPage(page,
      duration: Duration(milliseconds: 800), curve: Curves.bounceInOut);
}

bool _loading = false;
bool _isRoot = false;
String error = '';
DocumentSnapshot _doc;
void inits() async {
  _isRoot = await isRoot;
  goToPage(_isRoot ? 0 : 1);
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    setState(() {
      _doc = null;
    });
    _loading = false;
    inits();
    return _loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
                backgroundColor: Colors.blue[700],
                title: Text('Registrarme'),
                centerTitle: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(80)))),
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: PageView(
                    controller: _controller,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[RegisterNew(), Key()])));
  }
}

class RegisterNew extends StatefulWidget {
  @override
  _RegisterNewState createState() => _RegisterNewState();
}

class _RegisterNewState extends State<RegisterNew> {
  int level = -1;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController(),
      _lastNameController = TextEditingController(),
      _phoneController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController();
  String leader = '';
  @override
  Widget build(BuildContext context) {
    if (_doc != null) {
      if (_nameController.text == '')
        _nameController = TextEditingController(text: _doc.data['name']);
      if (_lastNameController.text == '')
        _lastNameController =
            TextEditingController(text: _doc.data['lastName']);
      if (_phoneController.text == '')
        _phoneController = TextEditingController(text: _doc.data['phone']);
      leader = _doc.data['leader'];
    }
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: textInputDecoration.copyWith(
                  labelText: 'Nombre', icon: Icon(Icons.short_text)),
              validator: (val) => val.isEmpty ? 'Ingrese su nombre' : null),
          SizedBox(height: 10),
          TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: textInputDecoration.copyWith(
                  labelText: 'Apellido', icon: Icon(Icons.short_text)),
              validator: (val) => val.isEmpty ? 'Ingrese su apellido' : null),
          SizedBox(height: 10),
          TextFormField(
              maxLength: 10,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: textInputDecoration.copyWith(
                  labelText: 'Teléfono', icon: Icon(Icons.phone))),
          TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: textInputDecoration.copyWith(
                  labelText: 'Correo electrónico', icon: Icon(Icons.email)),
              validator: (val) =>
                  val.isEmpty ? 'Ingrese un correo electrónico' : null),
          TextFormField(
              controller: _passwordController,
              decoration: textInputDecoration.copyWith(
                  labelText: 'Contraseña', icon: Icon(Icons.visibility_off)),
              obscureText: true,
              validator: (val) =>
                  val.length < 8 ? 'Debe tener mínimo 8 caracteres' : null),
          Row(children: <Widget>[
            Icon(Icons.person, color: Colors.grey),
            Flexible(child: Text('    $leader'))
          ]),
          RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  dynamic result;
                  setState(() => _loading = true);
                  if (_isRoot) {
                    result = await _auth.registerEmail(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                        _lastNameController.text,
                        _phoneController.text,
                        leader,
                        level + 1);
                  } else {
                    result = await _auth.registerExisting(
                        _doc,
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                        _lastNameController.text,
                        _phoneController.text);
                  }
                  if (result == null) {
                    setState(() {
                      error = 'Por favor, verifique sus datos';
                      _loading = false;
                    });
                  }
                }
              },
              child: Text('Registrarme', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          Text(error, style: TextStyle(color: Colors.red, fontSize: 14)),
          Text('¿Ya tienes una cuenta?'),
          RaisedButton(
              onPressed: () {
                goToPageMain(0);
              },
              child: Text(
                'Inicia sesión',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              color: Colors.grey.shade100,
              elevation: 0)
        ]),
      ),
    );
  }
}

class Key extends StatefulWidget {
  @override
  _KeyState createState() => _KeyState();
}

class _KeyState extends State<Key> {
  TextEditingController _codeController = TextEditingController();
  void _searchKey(String key) async {
    setState(() => _loading = true);
    DocumentSnapshot _d = await DatabaseService().getByKey(key);
    setState(() {
      if (_d == null) {
        error = 'Código no encontrado';
      } else {
        _doc = _d;
        error = '';
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_doc != null) if (_doc.data['waiting']) goToPage(0);
    return Column(
        children: _doc == null
            ? <Widget>[
                Text('\n\nIngrese el código proporcionado por su líder:\n'),
                TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                    decoration:
                        textInputDecoration.copyWith(labelText: 'Código'),
                    onChanged: (s) {
                      if (s.length == 5) _searchKey(s);
                    }),
                SizedBox(height: 25),
                RaisedButton(
                    child: Text('Continuar'),
                    onPressed: () => _searchKey(_codeController.text),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20))),
                Text(error, style: TextStyle(color: Colors.red, fontSize: 14)),
                Text('\n\n\n¿Ya tienes una cuenta?'),
                RaisedButton(
                    onPressed: () {
                      goToPageMain(0);
                    },
                    child: Text('Inicia sesión',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    color: Colors.grey.shade100,
                    elevation: 0)
              ]
            : <Widget>[
                Text('Oops!', style: TextStyle(fontSize: 20)),
                Text(
                    'Lo sentimos ${_doc.data['name']}, tu líder principal aún no ha aprobado tu solicitud.'),
                RaisedButton(
                    onPressed: () {
                      setState(() {
                        _doc = null;
                      });
                    },
                    child: Text('Volver',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    color: Colors.grey.shade100,
                    elevation: 0)
              ]);
  }
}
