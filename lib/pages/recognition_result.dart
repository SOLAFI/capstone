import 'package:capstone/widgets/text.dart';
import 'package:flutter/material.dart';

class PredictionResultPage extends StatefulWidget{
  PredictionResultPage({Key? key, required this.postResponse}) : super(key: key);

  final Map<String, dynamic> postResponse;

  @override
  _PredictionResultPageState createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {

  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mediaHeight = mediaQueryData.size.height;
    double mediaWidth = mediaQueryData.size.width;

    Map result = widget.postResponse;
    String className = result['class_name'];
    String summary = result['summary'];
    String imageURL = result['image_url'];
    String pageURL = result['page_url'];
    String orderName = result['taxonomy']['order_name'];
    String familyName = result['taxonomy']['family_name'];
    String genusName = result['taxonomy']['genus_name'];
    String speciesName = result['taxonomy']['species_name'];


    return Card(
      shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SizedBox(
        width: mediaWidth,
        height: mediaHeight*0.85,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PoppinsTitleText('Result:', 20, Colors.grey),
                PoppinsTitleText(className, 30, Colors.black),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 500,
                      maxWidth: 400,
                    ),
                    child: Image.network(imageURL),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order: '),
                          Text(orderName)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Family: '),
                          Text(familyName)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Genus: '),
                          Text(genusName)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Species: '),
                          Text(speciesName)
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(summary),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("\nSee full wiki page at: "+ pageURL),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}