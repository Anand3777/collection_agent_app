import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/chit_details.dart';
import '../services/smartflo_service.dart';
import 'call_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final SmartFloService _smartFloService = SmartFloService();
  
  List<User> users = [];
  List<User> filteredUsers = [];
  String selectedFilter = 'all';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers({String? status}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _smartFloService.getUsers(
      status: status,
    );

    setState(() {
      isLoading = false;
      if (result['success'] == true) {
        users = result['users'] ?? [];
        _filterUsers(selectedFilter);
        print('[UsersListScreen] Fetched ${users.length} users');
      } else {
        errorMessage = result['message'] ?? 'Failed to load users';
        users = [];
        filteredUsers = [];
        print('[UsersListScreen] Error: $errorMessage');
      }
    });
  }

  void _navigateToCallScreen(User user) {
    final chitDetails = ChitDetails(
      customerId: user.id,
      customerName: user.name,
      pendingAmount: user.pendingAmount,
      dueDate: user.dueDate,
      chitCycle: '14/20 Months',
      currentMonth: 14,
      totalMonths: 20,
      isCallActive: false,
      phoneNumber: user.phoneNumber,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(chitDetails: chitDetails),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'overdue':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Collection Users',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _fetchUsers(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    // Filter Tabs
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          _buildFilterButton('all', 'All Users'),
                          const SizedBox(width: 12),
                          _buildFilterButton('overdue', 'Overdue'),
                          const SizedBox(width: 12),
                          _buildFilterButton('pending', 'Pending'),
                        ],
                      ),
                    ),

                    // Users Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${filteredUsers.length} users',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'All: ${users.length}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Users List
                    if (filteredUsers.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(filteredUsers[index]);
                          },
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Users',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _fetchUsers(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String value, String label) {
    final isSelected = selectedFilter == value;
    return ElevatedButton(
      onPressed: () => _filterUsers(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : const Color(0xFF1E2A47),
        foregroundColor: isSelected ? Colors.white : Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.white10,
            width: 2,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  void _filterUsers(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'overdue') {
        filteredUsers = users.where((user) => user.status == 'overdue').toList();
      } else if (filter == 'pending') {
        filteredUsers = users.where((user) => user.status == 'pending').toList();
      } else {
        filteredUsers = users;
      }
    });
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCallScreen(user),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${user.id}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(user.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(user.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(user.status),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailColumn('Pending Amount', '₹${user.pendingAmount.toStringAsFixed(0)}'),
                    _buildDetailColumn('Due Date', _formatDate(user.dueDate)),
                    _buildDetailColumn('Overdue Days', '${user.overdueDays} days'),
                  ],
                ),

                const SizedBox(height: 16),

                // Call Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToCallScreen(user),
                    icon: const Icon(Icons.call),
                    label: const Text('Initiate Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
