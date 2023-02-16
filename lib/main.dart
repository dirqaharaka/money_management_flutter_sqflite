import 'package:flutter/material.dart';
import 'package:flutter_crud_sqflite/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'dr1xq Outcome',
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
 
 
        ),

        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();


  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _amountController.text = existingJournal['amounts'];
      _descriptionController.text = existingJournal['description'];
      _dateController.text = existingJournal['dates'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(hintText: 'Amount'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(hintText: 'Date'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new item
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';
                      _amountController.text = '';
                      _descriptionController.text = '';
                      _dateController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    
    await SQLHelper.createItem(
        _titleController.text,
        _amountController.text,
        _descriptionController.text,
        _dateController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id,
        _titleController.text,
        _amountController.text,
        _descriptionController.text,
        _dateController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a item !'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Container(
          alignment: Alignment.center,
          child: const Text('dr1xq Outcome Notes'),
        ),
      ),
      body: _isLoading
          ? const Center( 
              child: CircularProgressIndicator(),
            )
          : ListView.builder(  
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Color.fromARGB(255, 11, 11, 11),
                shadowColor: Color.fromARGB(255, 0, 0, 0),
                margin: const EdgeInsets.all(10),
                child: ListTile(
                    title: Text(_journals[index]['title'],  style: TextStyle(color: Colors.green, fontSize: 18.0)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rp. ${_journals[index]['amounts']}",  style: TextStyle(color: Colors.green)),
                        Text(_journals[index]['description'],  style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 175,
                      child: Row(
                        children: [
                        Text(_journals[index]['dates'],  style: TextStyle(color: Colors.green)),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.green,
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () =>
                                _deleteItem(_journals[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
