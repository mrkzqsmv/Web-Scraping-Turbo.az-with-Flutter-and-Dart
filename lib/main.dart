import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:web_scraping_app_with_flutter/car_model.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  var url = Uri.parse('https://turbo.az/');
  List cars = [];
  // image => element.children[3].children[0].attributes['src'].toString()
  // price => element.children[4].children[0].children[0].text
  // name => element.children[4].children[1].text
  // feature => element.children[4].children[2].text
  // country and time => element.children[4].children[3].text
  Future getData() async {
    setState(() {
      isLoading = true;
    });
    var res = await http.get(url);
    final body = res.body;
    final document = htmlParser.parse(body);
    var response = document
        .getElementsByClassName('products')[0]
        .getElementsByClassName('products-i')
        .forEach((element) {
      setState(() {
        cars.add(
          CarModel(
            carName: element.children[4].children[1].text.toString(),
            carImgPath:
                element.children[3].children[0].attributes['src'].toString(),
            carFeature: element.children[4].children[2].text.toString(),
            carPrice:
                element.children[4].children[0].children[0].text.toString(),
            date: element.children[4].children[3].text.toString(),
          ),
        );
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue.shade100,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade500,
          title: Text(
            'Turbo.az Web Scraping',
            style: GoogleFonts.aBeeZee(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: SimpleCircularProgressBar(
                  mergeMode: true,
                  onGetText: (double value) {
                    return Text('${value.toInt()}%');
                  },
                ),
              )
            : SafeArea(
                child: GridView.builder(
                  itemCount: cars.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white.withOpacity(0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Image.network(
                              cars[index].carImgPath,
                              width: MediaQuery.of(context).size.width * 0.3,
                            ),
                            Text(
                              cars[index].carPrice.toString(),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              cars[index].carName.toString(),
                            ),
                            Text(cars[index].carFeature.toString()),
                            Text(
                              cars[index].date.toString(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
