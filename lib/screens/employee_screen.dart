import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/sqlite_helper.dart';
import '../widgets/employee_form_sheet.dart';
import 'user_data_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshEmployees();
  }

  Future<void> _refreshEmployees() async {
    final data = await SqliteHelper.getItems();
    if (!mounted) return;
    setState(() {
      _employees = data;
      _isLoading = false;
    });
  }

  Future<void> _handleSaveEmployee(Employee employee) async {
    if (employee.id == null) {
      await SqliteHelper.createItem(employee);
      _showSnackbar('Employee created successfully');
    } else {
      await SqliteHelper.updateItem(employee);
      _showSnackbar('Employee updated successfully');
    }
    await _refreshEmployees();
  }

  Future<void> _deleteEmployee(int id) async {
    await SqliteHelper.deleteItem(id);
    _showSnackbar('Employee deleted successfully');
    await _refreshEmployees();
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await _deleteEmployee(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Employee SQLite CRUD'),
        actions: [
          IconButton(
            tooltip: 'JSONPlaceholder Posts API',
            icon: const Icon(Icons.api_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserDataScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
              ? const Center(
                  child: Text(
                    'No employees found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshEmployees,
                  child: ListView.builder(
                    itemCount: _employees.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final employee = _employees[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        color: Colors.orange.shade50,
                        child: ListTile(
                          title: Text(
                            employee.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phone: ${employee.number}'),
                                const SizedBox(height: 2),
                                Text('Email: ${employee.email}'),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  EmployeeFormSheet.show(
                                    context,
                                    employee: employee,
                                    onSave: _handleSaveEmployee,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (employee.id != null) {
                                    _confirmDelete(employee.id!);
                                  }
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
          EmployeeFormSheet.show(
            context,
            onSave: _handleSaveEmployee,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
