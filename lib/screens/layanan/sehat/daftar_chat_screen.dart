import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reang_app/models/dokter_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'chat_screen.dart';

class DaftarChatScreen extends StatefulWidget {
  const DaftarChatScreen({super.key});

  @override
  State<DaftarChatScreen> createState() => _DaftarChatScreenState();
}

class _DaftarChatScreenState extends State<DaftarChatScreen> {
  final ApiService _apiService = ApiService();
  Stream<QuerySnapshot>? _chatsStream;
  StreamSubscription<User?>? _authSub;

  // Cache futures untuk menghindari fetch ulang setiap rebuild
  final Map<String, Future<DokterModel?>> _dokterCache = {};

  @override
  void initState() {
    super.initState();
    _initializeStream();

    // Hanya re-init stream jika UID berubah (mis. login/logout)
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final currentUid = _chatsStream == null
          ? null
          : FirebaseAuth.instance.currentUser?.uid;
      if (user?.uid != currentUid) {
        // Ganti stream hanya kalau benar-benar berubah
        _initializeStream();
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _initializeStream() {
    final myId = FirebaseAuth.instance.currentUser?.uid;
    if (myId != null) {
      // gunakan query stream langsung (disimpan sekali di init atau saat uid berubah)
      _chatsStream = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: myId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots();
    } else {
      _chatsStream = const Stream.empty();
    }
  }

  Future<DokterModel?> _getDokterFuture(String adminId) {
    if (adminId.isEmpty) {
      // return a completed future with null to avoid unnecessary calls
      return Future.value(null);
    }
    return _dokterCache.putIfAbsent(
      adminId,
      () => _apiService.getDokterByAdminId(adminId),
    );
  }

  String getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> names = name.split(' ');
    String initials = '';
    int numWords = names.length > 1 ? 2 : 1;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final messageDate = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (messageDate.isAfter(today))
      return DateFormat('HH:mm').format(messageDate);
    if (messageDate.isAfter(yesterday)) return 'Kemarin';
    return DateFormat('dd/MM/yy').format(messageDate);
  }

  // helper: tampilkan loading dialog (blocking kecil)
  Future<void> _showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser?.uid;

    if (myId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // pakai stream yang sudah dibuat di initState (jangan re-create lagi di build)
        stream: _chatsStream,
        builder: (context, snapshot) {
          // Jika stream belum siap (initial) tampilkan shimmer
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Anda belum memulai percakapan.'));
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chatDocs.length,
            separatorBuilder: (context, index) =>
                const Divider(indent: 80, height: 1),
            itemBuilder: (context, index) {
              final chatDoc = chatDocs[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              String recipientName = 'Dokter';
              String recipientAdminId = '';
              final pNames = List<String>.from(
                chatData['participantNames'] ?? [],
              );
              final pIds = List<String>.from(chatData['participants'] ?? []);

              for (int i = 0; i < pIds.length; i++) {
                if (pIds[i] != myId) {
                  recipientAdminId = pIds[i];
                  // Ambil nama dari participantNames jika tersedia
                  if (i < pNames.length) {
                    final nameParts = pNames[i].split(' ');
                    if (nameParts.length > 1 &&
                        (nameParts[0] == 'Dr.' || nameParts[0] == 'dr.')) {
                      recipientName = nameParts.sublist(1).join(' ');
                    } else {
                      recipientName = pNames[i];
                    }
                  }
                  break;
                }
              }

              final unreadCount = ((chatData['unreadCount'] ?? {})[myId] ?? 0)
                  .toInt();
              final hasUnread = unreadCount > 0;

              // PREFETCH ringan: minta future berjalan sedini mungkin (tidak awaited)
              _getDokterFuture(recipientAdminId);

              return FutureBuilder<DokterModel?>(
                // gunakan future cached agar tidak re-fetch setiap snapshot update
                future: _dokterCache[recipientAdminId],
                builder: (context, dokterSnapshot) {
                  // Jika dokterSnapshot sedang menunggu dan kita belum pernah mem-fetch sebelumnya,
                  // tampilkan placeholder kecil (tapi bukan shimmer full list) — agar tidak mengganti seluruh daftar.
                  if (dokterSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !_dokterCache.containsKey(recipientAdminId)) {
                    return _buildShimmerTile();
                  }

                  final dokter = dokterSnapshot.data;
                  final displayName = dokter?.nama ?? recipientName;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          (dokter?.fotoUrl != null &&
                              dokter!.fotoUrl!.isNotEmpty)
                          ? NetworkImage(dokter.fotoUrl!)
                          : null,
                      child:
                          (dokter?.fotoUrl == null || dokter!.fotoUrl!.isEmpty)
                          ? Text(
                              getInitials(displayName),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: hasUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      chatData['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTimestamp(
                            chatData['lastMessageTimestamp'] as Timestamp?,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? Colors.green
                                : Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 24, height: 24),
                      ],
                    ),
                    onTap: () async {
                      // Set unreadCount to 0 (fire-and-forget) supaya UI cepat
                      chatDoc.reference
                          .set({
                            'unreadCount': {myId: 0},
                          }, SetOptions(merge: true))
                          .catchError((e) {});

                      // Tampilkan loading kecil agar user tahu proses fetch sedang berjalan.
                      _showLoadingDialog(context);

                      DokterModel? dokterToOpen;
                      try {
                        // Tunggu maksimal 7 detik agar tidak menggantung
                        dokterToOpen = await _getDokterFuture(
                          recipientAdminId,
                        ).timeout(const Duration(seconds: 7));
                      } on TimeoutException {
                        dokterToOpen = null;
                      } catch (e) {
                        dokterToOpen = null;
                      }

                      // Tutup dialog loading jika masih terbuka
                      if (mounted)
                        Navigator.of(context, rootNavigator: true).pop();

                      if (dokterToOpen == null) {
                        // Gagal fetch dokter — beri info dan jangan buka ChatScreen karena ChatScreen butuh DokterModel valid
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gagal memuat data dokter. Coba lagi.',
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      // Sekarang navigasi ke ChatScreen dengan dokter yang valid
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(recipient: dokterToOpen),
                        ),
                      );

                      // Setelah kembali dari ChatScreen, pastikan unread lagi (fire-and-forget)
                      if (!mounted) return;
                      chatDoc.reference
                          .set({
                            'unreadCount': {myId: 0},
                          }, SetOptions(merge: true))
                          .catchError((e) {});
                      if (mounted) setState(() {});
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Widget untuk Shimmer Effect (Loading)
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: ListView.separated(
        itemCount: 8,
        separatorBuilder: (context, index) =>
            const Divider(indent: 80, height: 1),
        itemBuilder: (context, index) => _buildShimmerTile(),
      ),
    );
  }

  // Widget untuk satu item Shimmer Tile
  Widget _buildShimmerTile() {
    return const ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(radius: 28, backgroundColor: Colors.white),
      title: ShimmerBox(width: 150, height: 16),
      subtitle: ShimmerBox(width: 200, height: 14),
      trailing: ShimmerBox(width: 50, height: 12),
    );
  }
}

// Widget helper kecil untuk kotak shimmer
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const ShimmerBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
