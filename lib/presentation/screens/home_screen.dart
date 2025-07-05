import 'package:connect/data/repositories/auth_repository.dart';
import 'package:connect/data/repositories/chat_repository.dart';
import 'package:connect/data/repositories/contact_repository.dart';
import 'package:connect/data/services/service_locator.dart';
import 'package:connect/logic/cubits/auth/auth_cubit.dart';
import 'package:connect/presentation/screens/auth/login_screen.dart';
import 'package:connect/presentation/screens/chat_message_screen.dart';
import 'package:connect/presentation/widgets/chat_list_tile.dart';
import 'package:connect/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentUser?.uid ?? "";
    super.initState();
  }

  void _showContactsList(BuildContext context) async {
    // await _contactRepository.debugRegisteredUsers();
    // Check permission first
    final permission = await Permission.contacts.request();

    if (permission.isDenied) {
      final result = await Permission.contacts.request();
      if (result.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact permission is required')),
        );
        return;
      }
    }

    if (permission.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable contact permission in settings'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error getting contacts"));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    print(snapshot);
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return Center(child: Text("No contacts found"));
                    }
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(contact["name"][0].toUpperCase()),
                          ),
                          title: Text(contact["name"]),
                          onTap: () {
                            getIt<AppRouter>().push(
                              ChatMessageScreen(
                                receiverId: contact["id"],
                                receiverName: contact["name"],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () async {
                await getIt<AuthCubit>().signOut();
                getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _chatRepository.getChatRooms(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return Center(child: Text("No recent chats"));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatListTile(
                chat: chat,
                currentUserId: _currentUserId,
                onTap: () {
                  final otherUserId = chat.participants.firstWhere(
                    (id) => id != _currentUserId,
                  );
                  final otherUserName =
                      chat.participantsName![otherUserId] ?? "Unknown";
                  getIt<AppRouter>().push(
                    ChatMessageScreen(
                      receiverId: otherUserId,
                      receiverName: otherUserName,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactsList(context),
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
