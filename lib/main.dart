import 'package:flutter/material.dart';
import 'package:interview/services/Sqlitehelper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite CRUD',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
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


  List<Map<String, dynamic>> _employees = [];

  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _numberController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _refreshEmployees();
  }

  Future<void> _refreshEmployees() async {
    final data = await SQLHelper.getItems();

    if (!mounted) return;

    setState(() {
      _employees = data;
      _isLoading = false;
    });
  }


  void _showForm(int? id) async {

    if (id != null) {

      final existingEmployee =
      _employees.firstWhere((element) => element['id'] == id,);

      _nameController.text = existingEmployee['name'] ?? '';

      _numberController.text = existingEmployee['number'] ?? '';

      _emailController.text = existingEmployee['email'] ?? '';
    }
    else {
      _nameController.clear();
      _numberController.clear();
      _emailController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,

      builder: (context) {

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),
                TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  maxLength: 13,
                  decoration: const InputDecoration(
                    labelText: 'Number',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () async {

                      // Validation
                      if (_nameController.text.trim().isEmpty || _numberController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill all fields',
                            ),
                          ),
                        );

                        return;
                      }

                      if (id == null) {
                        await _addItem();
                      }

                      // UPDATE
                      else {
                        await _updateItem(id);
                      }

                      // Clear fields
                      _nameController.clear();
                      _numberController.clear();
                      _emailController.clear();

                      // Close bottom sheet
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },

                    child: Text(
                      id == null
                          ? 'Create Employee'
                          : 'Update Employee',
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


  Future<void> _addItem() async {

    await SQLHelper.createItem(
      _nameController.text.trim(),
      _numberController.text.trim(),
      _emailController.text.trim(),
    );

    await _refreshEmployees();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Employee created successfully',
        ),
      ),
    );
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> _updateItem(int id) async {

    await SQLHelper.updateItem(
      id,
      _nameController.text.trim(),
      _numberController.text.trim(),
      _emailController.text.trim(),
    );

    await _refreshEmployees();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Employee updated successfully',
        ),
      ),
    );
  }


  Future<void> _deleteItem(int id) async {

    await SQLHelper.deleteItem(id);

    await _refreshEmployees();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Employee deleted successfully',
        ),
      ),
    );
  }

  // =========================
  // DELETE CONFIRMATION
  // =========================

  void _confirmDelete(int id) {

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(
          title: const Text(
            'Delete Employee',
          ),

          content: const Text(
            'Are you sure you want to delete this employee?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {

                Navigator.pop(context);

                await _deleteItem(id);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {

    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: kToolbarHeight,
        centerTitle: false,
        title: const Text(
          'Employee SQLite CRUD',
        ),
      ),

      body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
           )

          : _employees.isEmpty

          ? const Center(
            child: Text(
          'No employees found',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
          )
          : RefreshIndicator(
        onRefresh: ()async {
          setState(() {
            _isLoading = true;
          });
          await _refreshEmployees();
        },
            child: ListView.builder(

                    itemCount: _employees.length,

                    itemBuilder: (context, index,) {

            final employee =
            _employees[index];

            return Card(
              margin: const EdgeInsets.all(10),
              color: Colors.orange.shade100,
              child: ListTile(
                title: Text(
                  employee['name'] ?? '',
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Phone: ${employee['number'] ?? ''}',
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Email: ${employee['email'] ?? ''}',
                    ),
                  ],
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min,

                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                      ),

                      onPressed: () {
                        _showForm(
                          employee['id'],
                        );
                      },
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                      ),

                      onPressed: () {
                        _confirmDelete(
                          employee['id'],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
                    },
                  ),
          ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {
          _showForm(null);
        },

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}