import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momentum/controllers/amistats_controller.dart';
import 'package:momentum/models/amistat_model.dart';

class AmistatsScreen extends StatelessWidget {
  final FriendController controller = Get.find<FriendController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Amistats')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            // Buscador d’usuari
            Obx(() {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue[50],
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                hintText: 'Cerca per correu...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueAccent, width: 2.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.search),
                                      onPressed: () => controller
                                          .searchUserByEmail(controller
                                              .emailController.text),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        controller.emailController.clear();
                                        controller.clearSearchResults();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (controller.isLoading.value)
                        CircularProgressIndicator()
                      else if (controller.searchResults.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.searchResults.length,
                          itemBuilder: (context, index) {
                            final user = controller.searchResults[index];
                            return Card(
                              child: ListTile(
                                title: Text(user.mail),
                                trailing: IconButton(
                                  icon:
                                      Icon(Icons.person_add_alt_1, color: Colors.blue),
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    final myId = prefs.getString('userId');
                                    if (myId != null) {
                                      controller.sendFriendRequest(myId, user.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),

            // Sol·licituds d’amistat
            Obx(() {
              final isExpanded = controller.showRequestsVertical.value;
              final requests = controller.friendsRequests;

              return Visibility(
                visible: requests.isNotEmpty,
                child: GestureDetector(
                  onLongPress: controller.toggleRequestsView,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blue[50],
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sol·licituds d\'amistat',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          isExpanded
                            ? ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: requests.map((user) => _requestTile(user)).toList(),
                              )
                            : SizedBox(
                                height: 70,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: requests.map((user) => _requestTile(user)).toList(),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),

            // Amics
            Obx(() {
              final friends = controller.friends;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue[50],
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amics',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (friends.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Encara no tens cap amic!'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side:
                                    BorderSide(color: Colors.blue.shade200),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.account_circle_rounded, color: Colors.blue),
                                title: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    friend.mail,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.person_remove, color: Colors.red),
                                  onPressed: () => controller.removeFriend(friend.id),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _requestTile(AmistatModel user) {
    final isVertical = controller.showRequestsVertical.value;

    return Container(
      width: isVertical ? double.infinity : 300, 
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isVertical
            ? Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    user.mail,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : Expanded(
                child: Text(
                  user.mail,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => controller.acceptFriendRequest(user.id),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => controller.denyFriendRequest(user.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

