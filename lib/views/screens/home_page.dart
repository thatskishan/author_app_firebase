import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../helpers/firestore_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  final TextEditingController authorController = TextEditingController();
  final TextEditingController bookController = TextEditingController();

  String? author;
  String? book;
  Uint8List? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Authors & Books",
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff142841),
      ),
      backgroundColor: const Color(0xff23334c),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("author").snapshots(),
        builder: (context, snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("ERROR:${snapShot.error}"),
            );
          } else if (snapShot.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = snapShot.data;

            if (data == null) {
              return const Center(
                child: Text("No Data Available"),
              );
            } else {
              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  data.docs;

              return ListView.builder(
                itemCount: allDocs.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            foregroundImage:
                                (allDocs[i].data()['image'] == null)
                                    ? null
                                    : MemoryImage(
                                        base64Decode(
                                          allDocs[i].data()['image'],
                                        ),
                                      ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "${allDocs[i].data()['book']}",
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              "- ${allDocs[i].data()['author']}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff142841),
        onPressed: () {
          validateAndInsert();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  getImage() async {
    ImagePicker picker = ImagePicker();

    XFile? xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    image = await xFile!.readAsBytes();
  }

  validateAndInsert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add record",
          style: GoogleFonts.poppins(),
        ),
        content: Form(
          key: insertKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xff23334c),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: authorController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter Author Name First";
                  }
                  return null;
                },
                onSaved: (val) {
                  author = val;
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Author Name First",
                  labelText: "Author",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: bookController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter Book Name First";
                  }
                  return null;
                },
                onSaved: (val) {
                  book = val;
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Book Name Here",
                  labelText: "Book",
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () async {
              if (insertKey.currentState!.validate()) {
                insertKey.currentState!.save();

                Map<String, dynamic> record = {
                  "author": author,
                  "book": book,
                  "image": base64Encode(image!),
                };

                await FirestoreHelper.firestoreHelper
                    .insertRecord(data: record);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Record inserted successfully..."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                authorController.clear();
                bookController.clear();

                setState(() {
                  author = null;
                  book = null;
                  image = null;
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "Add",
              style: GoogleFonts.poppins(),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              authorController.clear();
              bookController.clear();

              setState(() {
                author = null;
                book = null;
                image = null;
              });
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  updateAndInsert({required String id, required Map<String, dynamic> data}) {
    authorController.text = data['author'];
    bookController.text = data['book'];
    image = base64Decode(data['image']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add record",
          style: GoogleFonts.poppins(),
        ),
        content: Form(
          key: updateKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xff23334c),
                  foregroundImage: (image != null) ? MemoryImage(image!) : null,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: authorController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter Author NameFirst";
                  }
                  return null;
                },
                onSaved: (val) {
                  author = val;
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter AuthorName Here",
                  labelText: "Author",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: bookController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter Book Name First";
                  }
                  return null;
                },
                onSaved: (val) {
                  book = val;
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Book Name Here",
                  labelText: "Book",
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () async {
              if (updateKey.currentState!.validate()) {
                updateKey.currentState!.save();

                Map<String, dynamic> record = {
                  "author": author,
                  "book": book,
                  "image": base64Encode(image!),
                };

                await FirestoreHelper.firestoreHelper
                    .updateRecord(data: record, id: id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Record Updated successfully..."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                authorController.clear();
                bookController.clear();

                setState(() {
                  author = null;
                  book = null;
                  image = null;
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "Update",
              style: GoogleFonts.poppins(),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              authorController.clear();
              bookController.clear();

              setState(() {
                author = null;
                book = null;
                image = null;
              });
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
