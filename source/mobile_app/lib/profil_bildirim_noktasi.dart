import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilBildirimNoktasi extends StatelessWidget {
  final Widget child;

  const ProfilBildirimNoktasi({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return child;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('booking_requests')
          .snapshots(),
      builder: (context, requestSnapshot) {
        bool istekBildirimiVar = false;

        if (requestSnapshot.hasData) {
          for (final doc in requestSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final bool gelenIstekBildirimi =
                data['providerId'] == user.uid &&
                data['providerSeen'] == false;

            final bool gonderilenIstekBildirimi =
                data['customerId'] == user.uid &&
                data['customerSeen'] == false;

            if (gelenIstekBildirimi || gonderilenIstekBildirimi) {
              istekBildirimiVar = true;
              break;
            }
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where(
                'unreadFor',
                arrayContains: user.uid,
              )
              .snapshots(),
          builder: (context, messageSnapshot) {
            final bool mesajBildirimiVar =
                messageSnapshot.hasData &&
                messageSnapshot.data!.docs.isNotEmpty;

            final bool bildirimVar =
                istekBildirimiVar || mesajBildirimiVar;

            return Stack(
              children: [
                child,
                if (bildirimVar)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}