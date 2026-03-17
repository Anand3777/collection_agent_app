import 'package:flutter/material.dart';
import 'dart:async';
import 'web_socket_client.dart';
import '../models/chit_details.dart';
import '../models/chat_message.dart';
import '../services/smartflo_service.dart';
import '../widgets/calling_dialog.dart';
import 'dart:js' as js;

class CallScreen extends StatefulWidget {
  final ChitDetails chitDetails;

  const CallScreen({Key? key, required this.chitDetails}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final SmartFloService _smartFloService = SmartFloService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  WebSocketClient? _wsClient;
  bool _isCallActive = false;
  DateTime? _callStartTime;
  Timer? _callTimer;
  Timer? _callDurationTimer;
  String _callDuration = '00:00';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callDurationTimer?.cancel();
    _wsClient?.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Add initial system message
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: 'Hello ${widget.chitDetails.customerName}, this is System AI regarding your Chit payment for the month of October. We noticed it\'s overdue by ${widget.chitDetails.overdueDays} days. Would you like to pay now?',
      sender: MessageSender.system,
      timestamp: DateTime.now(),
      isRead: true,
    );
    
    setState(() {
      _messages.add(systemMessage);
    });
  }

  Future<void> _initiateCall() async {
    bool dialogShown = false;

    // Validate phone number
    if (widget.chitDetails.phoneNumber == null || widget.chitDetails.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show calling dialog immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        dialogShown = true;
        return CallingDialog(
          userName: widget.chitDetails.customerName,
          onEndCall: () => Navigator.of(context).pop(),
          onMute: () {},
          onSpeaker: () {},
        );
      },
    );

    // Use support API with just customer number from chitDetails
    final result = await _smartFloService.initiateSupportCall(
      customerNumber: widget.chitDetails.phoneNumber!,
    );

    // Close dialog if still open
    if (dialogShown && mounted) {
      Navigator.of(context).pop();
    }

    if (result['success'] == true) {
      setState(() {
        _isCallActive = true;
        _callStartTime = DateTime.now();
      });
      
      _startCallTimer();
      
      // Connect WebSocket for voice communication
      _wsClient ??= WebSocketClient();
      await _wsClient?.connect();
      
      // Listen to incoming WebSocket messages
      _wsClient?.messages.listen((message) {
        print('[CallScreen] WebSocket message received: $message');
        // Handle incoming voice data or messages here
      }, onError: (error) {
        print('[CallScreen] WebSocket error: $error');
        if (mounted) {
          _speakError('WebSocket connection failed');
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Call initiated: ${result['ref_id'] ?? 'Success'}'),
          backgroundColor: Colors.green,
        ),
      );

      // Stay on call screen for 30 seconds, then auto-disconnect
      _callDurationTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          _endCall();
        }
      });
    } else {
      // Speak error message
      _speakError('There is a technical issue, cannot connect now');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _speakError(String message) async {
    try {
      // Use browser's Web Speech API for text-to-speech
      js.context.callMethod('eval', ['''
        (function() {
          const utterance = new SpeechSynthesisUtterance('$message');
          utterance.rate = 0.5;
          utterance.pitch = 1.0;
          utterance.volume = 1.0;
          speechSynthesis.cancel();
          speechSynthesis.speak(utterance);
        })()
      ''']);
      print('[CallScreen] Voice message played: $message');
    } catch (e) {
      print('[CallScreen] Voice Error: $e');
      // Show dialog as fallback
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Connection Error'),
            content: Text(message),
            backgroundColor: Colors.red[700],
            contentTextStyle: const TextStyle(color: Colors.white),
            titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        final duration = DateTime.now().difference(_callStartTime!);
        setState(() {
          _callDuration = _formatDuration(duration);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _endCall() {
    _callTimer?.cancel();
    _wsClient?.disconnect();
    setState(() {
      _isCallActive = false;
      _callStartTime = null;
      _callDuration = '00:00';
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: _messageController.text.trim(),
      sender: MessageSender.agent,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    // Simulate customer response
    Future.delayed(const Duration(seconds: 2), () {
      final response = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Thank you for understanding. I will make the payment soon.',
        sender: MessageSender.customer,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      setState(() {
        _messages.add(response);
      });
    });
  }

  void _approveRequest() {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: 'Your request has been approved. The due date has been extended by 2 days.',
      sender: MessageSender.system,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(message);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request approved'),
        backgroundColor: Colors.green,
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.chitDetails.customerName} (#${widget.chitDetails.customerId})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (_isCallActive)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE CALL ACTIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green, size: 32),
            onPressed: _isCallActive ? null : _initiateCall,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCallActive ? _endCall : _initiateCall,
                    icon: Icon(_isCallActive ? Icons.call_end : Icons.call),
                    label: Text(_isCallActive ? 'END CALL' : 'JOIN LIVE CALL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCallActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.schedule),
                    label: const Text('Follow-up Needed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2A47),
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chit Details Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2238),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE CHIT DETAILS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Pending Amount', '₹${widget.chitDetails.pendingAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                _buildDetailRow('Due Date', _formatDate(widget.chitDetails.dueDate)),
                const SizedBox(height: 12),
                _buildDetailRow('Chit Cycle', '${widget.chitDetails.currentMonth}/${widget.chitDetails.totalMonths} Months'),
              ],
            ),
          ),

          // Call Timer
          if (_isCallActive)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3A5A),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'CALL STARTED $_callDuration',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Action Buttons Row
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.call,
                  label: 'JOIN CALL',
                  color: Colors.green,
                  onPressed: _isCallActive ? null : _initiateCall,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.link,
                  label: 'Send Link',
                  color: Colors.blue,
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Approve',
                  color: Colors.green,
                  onPressed: _approveRequest,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.call_end,
                  label: 'End',
                  color: Colors.red,
                  onPressed: _isCallActive ? _endCall : null,
                ),
              ],
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0066FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type to intervene manually...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF1A2238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0066FF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSystem = message.sender == MessageSender.system;
    final isCustomer = message.sender == MessageSender.customer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isSystem ? 'SYSTEM AI' : isCustomer ? '${widget.chitDetails.customerName.toUpperCase()} (CUSTOMER)' : 'AGENT',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCustomer) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSystem ? const Color(0xFF2A3A5A) : const Color(0xFF0066FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSystem ? Icons.smart_toy : Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCustomer ? const Color(0xFF0066FF) : const Color(0xFF2A3A5A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isCustomer) ...[
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/customer_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E2A47),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
