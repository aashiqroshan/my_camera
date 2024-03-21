import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();
  late Box<String> imagesBox;
  late List<String> imagepaths;

  @override
  void initState() {
    super.initState();
    imagesBox = Hive.box<String>('images');
    imagepaths = imagesBox.values.toList();
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagesBox.add(image.path);
      setState(() {
        imagepaths = imagesBox.values.toList();
      });

      await ImageGallerySaver.saveFile(image.path);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Image saved'),
            content: const Text('the Image has been saved to database and Gallery'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ok'))
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
              'My Camera',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.amber,
            bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    text: 'Camera',
                  ),
                  Tab(
                    text: 'Gallery',
                  )
                ])),
        body: TabBarView(children: [
          Container(
            child: Center(
              child: ElevatedButton(
                onPressed: _getImageFromCamera,
                child: Icon(Icons.camera_alt),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    elevation: 7,
                    shadowColor: Colors.black,
                    minimumSize: Size(70, 70)),
              ),
            ),
          ),
          Container(
              child: imagepaths.isEmpty
                  ? const Center(
                      child: Text('NO photos available'),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4),
                      itemCount: imagepaths.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.file(File(imagepaths[index])),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('close')),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    imagesBox.deleteAt(index);
                                                    imagepaths.removeAt(index);
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Delete'))
                                          ],
                                        )
                                      ]),
                                );
                              },
                            );
                          },
                          child: Image.file(
                            File(imagepaths[index]),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ))
        ]),
      ),
    );
  }
}
