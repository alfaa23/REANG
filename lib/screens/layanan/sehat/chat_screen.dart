import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Model sederhana untuk pesan
class ChatMessage {
  final String text;
  final bool isSender; // true jika dari pengguna, false jika dari dokter
  final String time;

  ChatMessage({required this.text, required this.isSender, required this.time});
}

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  const ChatScreen({super.key, required this.doctorData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Data dummy untuk percakapan
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Selamat pagi! Saya Dr. Sarah. Ada keluhan apa yang bisa saya bantu hari ini?',
      isSender: false,
      time: '09:15',
    ),
    ChatMessage(
      text:
          'Pagi dok, saya merasa pusing dan mual sejak kemarin. Apakah ini gejala yang serius?',
      isSender: true,
      time: '09:16',
    ),
    ChatMessage(
      text:
          'Terima kasih sudah menjelaskan keluhannya. Untuk membantu diagnosis yang lebih akurat, boleh saya tahu sudah berapa lama mengalami gejala ini? Dan apakah ada gejala lain yang menyertai?',
      isSender: false,
      time: '09:17',
    ),
    ChatMessage(
      text:
          'Sudah sekitar 2 hari dok. Selain pusing dan mual, saya juga merasa lemas dan tidak nafsu makan.',
      isSender: true,
      time: '09:18',
    ),
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(text: _controller.text, isSender: true, time: '09:19'),
        );
        _controller.clear();
      });
      // TODO: Kirim pesan ke backend Laravel
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      // TODO: Handle file gambar yang dipilih (upload ke server, dll)
      print('Image picked: ${image.path}');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // PERBAIKAN: Menghapus leading dan mengatur titleSpacing agar rapat ke kiri
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const BackButton(),
            const CircleAvatar(
              // Ganti dengan foto dokter jika ada
              child: Text('DS'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorData['nama'],
                  // PERBAIKAN: Menggunakan style yang sedikit lebih besar
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Ukuran font disesuaikan
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatMessageBubble(message: message);
              },
            ),
          ),
          _buildMessageComposer(theme),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: theme.hintColor),
              onPressed: _showImagePickerOptions,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan Anda...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk gelembung chat
class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSender = message.isSender;
    final alignment = isSender
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = isSender
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isSender
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          // PERBAIKAN: Menambahkan fontSize dan fontWeight
          child: Text(
            message.text,
            style: TextStyle(
              color: textColor,
              fontSize: 15, // Ukuran font diperbesar
              fontWeight: FontWeight.w500, // Ketebalan "semi-bold"
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message.time,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
