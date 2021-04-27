import 'package:audio_flutter_app/provider/audiomodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/AudioUsers.dart';

class ProfileEditPage extends StatefulWidget {
  static const routeName = '/editprofile';
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _displaynameFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = UserModel(displayname: '', imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'displayname': '',
    'imageUrl': '',
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _editedProduct = Provider.of<AudioUser>(context, listen: false).user;
      _initValues = {
        'displayname': _editedProduct.displayname,
        // 'imageUrl': _editedProduct.imageUrl,
        'imageUrl': _editedProduct.imageUrl,
      };
      _imageUrlController.text = _editedProduct.imageUrl;
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _displaynameFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!((_imageUrlController.text.startsWith('http') ||
              _imageUrlController.text.startsWith('https')) &&
          (_imageUrlController.text.endsWith('png') ||
              _imageUrlController.text.endsWith('jpg') ||
              !_imageUrlController.text.endsWith('jpeg')))) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.displayname == _initValues['displayname'] &&
        _editedProduct.imageUrl == _initValues['imageUrl']) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Channge Something'),
          content: Text('Channge Something to update !!!'),
          actions: [
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    } else {
      try {
        await Provider.of<AudioUser>(context, listen: false).changeprofile(
            _editedProduct.displayname, _editedProduct.imageUrl, context);
      } catch (err) {
        // throw (err);
        print(err.toString());
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured!!' + err.toString()),
            content: Text('Looks Like Something went wrong !!'),
            actions: [
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }

    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // print(_editedProduct.description);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['displayname'],
                      decoration: InputDecoration(labelText: 'displayname'),
                      focusNode: _displaynameFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return " Please provide a description";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = UserModel(
                          displayname: value,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter URL')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image Url'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return " Please provide a image";
                              } else if (!(value.startsWith('http') ||
                                  value.startsWith('https'))) {
                                return "Please provide valid image url";
                              } else if (!(value.endsWith('png') ||
                                  value.endsWith('jpeg') ||
                                  value.endsWith('jpg'))) {
                                return "Please provide valid image format";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _editedProduct = UserModel(
                                displayname: _editedProduct.displayname,
                                imageUrl: value,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
