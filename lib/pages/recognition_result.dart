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
        height: mediaHeight*0.82,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title label
                PoppinsTitleText('Result:', 20, Colors.grey, TextAlign.center),
                // Class name
                PoppinsTitleText(className, 28, Colors.black, TextAlign.center),
                // Wiki infobox image
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
                // Class details
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PoppinsTitleText('Order: ', 16, Colors.grey.shade500, TextAlign.start),
                              Text(orderName)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PoppinsTitleText('Family: ', 16, Colors.grey.shade600, TextAlign.start),
                              Text(familyName)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PoppinsTitleText('Genus: ', 16, Colors.grey.shade700, TextAlign.start),
                              Text(genusName)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PoppinsTitleText('Species: ', 16, Colors.grey.shade800, TextAlign.start),
                              Text(speciesName)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Report an issue'),
                    Icon(Icons.feedback),
                    Text('Helpful?'),
                    Icon(Icons.thumb_up),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: PoppinsTitleText('Summary', 24, Colors.black, TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(summary,
                  textAlign: TextAlign.justify,),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
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