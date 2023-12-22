import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

final List<String> _customers = [];
// domain of your server
const String _baseURL = 'csci410fall2023.000webhostapp.com';

class ShowCustomers extends StatefulWidget {
  const ShowCustomers({super.key});

  @override
  State<ShowCustomers> createState() => _ShowCustomersState();
}

class _ShowCustomersState extends State<ShowCustomers> {
  bool _load = false;

  void update(bool success) {
    setState(() {
      _load = true; // show product list
      if (!success) { // API request failed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('failed to load data')));
      }
    });
  }


  @override
  void initState() {
    // update data when the widget is added to the tree the first tome.
    updateCustomers(update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Available Customers'),
          centerTitle: true,
        ),
        body: _load ? const ListCustomers() : const Center(
            child: SizedBox(width: 100, height: 100, child: CircularProgressIndicator())
        )
    );
  }
}

class ListCustomers extends StatelessWidget {
  const ListCustomers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) => Column(children: [
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(child: Text(_customers[index], style: TextStyle(fontSize: 18)))
          ])
        ])
    );
  }
}

void updateCustomers(Function(bool success) update) async {
  try {
    final url = Uri.https(_baseURL, 'getCustomers.php');
    final response = await http.get(url)
        .timeout(const Duration(seconds: 5)); // max timeout 5 seconds
    _customers.clear(); // clear old products
    if (response.statusCode == 200) { // if successful call
      final jsonResponse = convert.jsonDecode(response.body); // create dart json object from json array
      for (var row in jsonResponse) { // iterate over all rows in the json array
        _customers.add('cid: ${row['cid']} name: ${row['name']} balance: ${row['balance']}');
      }
      update(true); // callback update method to inform that we completed retrieving data
    }
  }
  catch(e) {
    update(false); // inform through callback that we failed to get data
  }
}

