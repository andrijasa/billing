import 'package:billing/providers/screen_provider.dart';
import 'package:billing/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';


class UploadImages extends StatefulWidget {
  // final GlobalKey<ScaffoldState> globalKey;
  // const UploadImages({Key key, this.globalKey}) : super(key: key);
  @override
  _UploadImagesState createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Asset> images = List<Asset>();
  List<String> imageUrls = <String>[];
  String _error = 'No Error Dectected';
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        print(asset.getByteData(quality: 100));
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            
            height: 50,
            width: 50,
           
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenProvider = Provider.of<ScreenProvider>(context);

    if(images.length!=0) screenProvider.setAssetImage(images);
    images = screenProvider.getAssetImage;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Upload Images',
        ),
        elevation: 0.0,
        actions: <Widget>[
          Column(
            children: [
              Expanded(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: IconButton(
                    icon: Icon(Icons.reply),
                    iconSize: 30.0,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Notifications();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Notifications();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body:Stack(
      children: <Widget>[
        Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: loadAssets,
                      child: Text("Pick images",style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        screenProvider.setAssetImage(images);
                        Navigator.pop(context);
                        // if(images.length==0){
                        //   showDialog(context: context,builder: (_){
                        //     return AlertDialog(
                        //       backgroundColor: Theme.of(context).backgroundColor,
                        //      content: Text("No image selected",style: TextStyle(color: Colors.black54)),
                        //      actions: <Widget>[
                        //       InkWell(
                        //         onTap: (){
                        //           Navigator.pop(context);
                        //         },
                        //         child:  Text("Ok",style: TextStyle(color: Colors.black54),
                        //         ),
                        //       )
                        //      ],
                        //     );
                        //   });
                        // }
                        // else{
                        //   SnackBar snackbar = SnackBar(content: Text('Please wait, we are uploading'));
                        //   scaffoldKey.currentState.showSnackBar(snackbar);
                        //   uploadImages();
                        // }
                      },
                      child:  Text("Upload Images",style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: buildGridView(),
                )
              ],
            ),
          ),
      ],
    ));
  }
  void uploadImages(){
    for ( var imageFile in images) {
      postImage(imageFile).then((downloadUrl) {
        imageUrls.add(downloadUrl.toString());
        if(imageUrls.length==images.length){
          String documnetID = DateTime.now().millisecondsSinceEpoch.toString();
          Firestore.instance.collection('images').document(documnetID).setData({
            'urls':imageUrls
          }).then((_){
            SnackBar snackbar = SnackBar(content: Text('Uploaded Successfully'));
            scaffoldKey.currentState.showSnackBar(snackbar);
            setState(() {
              images = [];
              imageUrls = [];
            });
          });
        }
      }).catchError((err) {
        print(err);
      });
    }

  }
  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Upload Image",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      print(resultList.length);
      print((await resultList[0].getThumbByteData(122, 100)));
      print((await resultList[0].getByteData()));
      print((await resultList[0].metadata));

    } on Exception catch (e) {
      error = e.toString();
    }

  if (!mounted) return;
    setState(() {
      
      images = resultList;
      _error = error;
    });
    
  }
  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child('project/billing/company/$fileName');
    StorageUploadTask uploadTask = reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print('=======================================${storageTaskSnapshot.ref.getDownloadURL()}');
    storageTaskSnapshot.ref.getDownloadURL().then((value){print(value.toString()); });
    return storageTaskSnapshot.ref.getDownloadURL();
  }
}