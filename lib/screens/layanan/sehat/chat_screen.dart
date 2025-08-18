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

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // key untuk pesan terakhir agar ensureVisible
  final GlobalKey _lastMessageKey = GlobalKey();

  // key untuk composer agar bisa ukur tinggi composer
  final GlobalKey _composerKey = GlobalKey();

  // padding bottom yang dipakai ListView (komposerHeight + defaultPadding)
  double _listViewBottomPadding = 16.0;

  // apakah ListView saat ini bisa discroll (konten overflow)?
  bool _canScroll = false;

  // Data dummy untuk percakapan (urut dari atas ke bawah)
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _updateComposerHeightAndEnsureVisible(immediate: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateComposerHeightAndEnsureVisible(immediate: true);
      _updateCanScroll();
    });

    _scrollController.addListener(() {
      _updateCanScroll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // keyboard muncul/tutup => update composer height & pastikan pesan terakhir terlihat INSTANT
  @override
  void didChangeMetrics() {
    _updateComposerHeightAndEnsureVisible(immediate: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCanScroll());
    super.didChangeMetrics();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _controller.text,
            isSender: true,
            time: _currentTime(),
          ),
        );
        _controller.clear();
      });

      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateComposerHeightAndEnsureVisible(immediate: true);
        _updateCanScroll();
      });

      // TODO: Kirim pesan ke backend Laravel
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      print('Image picked: ${image.path}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateComposerHeightAndEnsureVisible(immediate: true);
        _updateCanScroll();
      });
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

  // ukur composer, set padding bottom = composerHeight + defaultPadding (JANGAN masukkan keyboard inset)
  void _updateComposerHeightAndEnsureVisible({bool immediate = false}) {
    double composerHeight = 0;
    try {
      final renderBox =
          _composerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        composerHeight = renderBox.size.height;
      }
    } catch (_) {
      composerHeight = 0;
    }

    final desiredPadding = 16.0 + composerHeight;

    if ((desiredPadding - _listViewBottomPadding).abs() > 1.0) {
      setState(() {
        _listViewBottomPadding = desiredPadding;
      });
    }

    _ensureLastMessageVisibleImmediate(immediate: immediate);
  }

  // pastikan pesan terakhir terlihat. immediate = true -> durasi zero
  void _ensureLastMessageVisibleImmediate({bool immediate = false}) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (_lastMessageKey.currentContext != null) {
          Scrollable.ensureVisible(
            _lastMessageKey.currentContext!,
            duration: immediate
                ? Duration.zero
                : const Duration(milliseconds: 1),
            alignment: 1.0,
            curve: Curves.easeOut,
          );
        } else if (_scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(max);
        }
      } catch (e) {
        // ignore jika belum siap
      }
    });
  }

  // Update _canScroll: jika maxScrollExtent > 0 => overflow => boleh scroll.
  // Selain itu: jika keyboard terbuka dan konten muat (max <=0), kita force non-scrollable.
  void _updateCanScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) {
      if (_canScroll != false) setState(() => _canScroll = false);
      return;
    }
    bool newCanScroll = false;
    try {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
      // Jika ada overflow, izinkan scroll. Jika tidak ada overflow but keyboard terbuka, disable scroll.
      newCanScroll = maxExtent > 0.0;
      if (!newCanScroll && keyboardOpen) {
        newCanScroll = false;
      }
    } catch (_) {
      newCanScroll = false;
    }
    if (newCanScroll != _canScroll) {
      setState(() => _canScroll = newCanScroll);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // pilih physics berdasarkan apakah konten overflow
    final ScrollPhysics physics = _canScroll
        ? const ClampingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    // AbsorbPointer digunakan untuk memblok gesture saat kita tidak ingin scroll,
    // ini mencegah user drag ke area kosong saat keyboard terbuka dan konten muat.
    final listView = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels > metrics.maxScrollExtent + 0.5) {
            if (_scrollController.hasClients) {
              try {
                _scrollController.jumpTo(metrics.maxScrollExtent);
              } catch (_) {}
            }
            return true;
          }
        }
        return false;
      },
      child: AbsorbPointer(
        absorbing: !_canScroll && MediaQuery.of(context).viewInsets.bottom > 0,
        child: ListView.builder(
          controller: _scrollController,
          physics: physics,
          padding: EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            _listViewBottomPadding,
          ),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            if (index == _messages.length - 1) {
              return Container(
                key: _lastMessageKey,
                child: _ChatMessageBubble(message: message),
              );
            } else {
              return _ChatMessageBubble(message: message);
            }
          },
        ),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const BackButton(),
            const CircleAvatar(child: Text('DS')),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorData['nama'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
          Expanded(child: listView),
          Container(
            key: _composerKey,
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
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: theme.hintColor,
                    ),
                    onPressed: _showImagePickerOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan Anda...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
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
          ),
        ],
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
          child: Text(
            message.text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
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
