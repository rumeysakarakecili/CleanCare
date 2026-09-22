import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilBildirimNoktasi extends StatelessWidget {
  final Widget child;

  const ProfilBildirimNoktasi({
    super.key,
    required this.child,
  });

  bool temizSnapshotMu(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) return false;
    if (snapshot.connectionState == ConnectionState.waiting) return false;


    return snapshot.data!.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return child;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('booking_requests')
          .where('providerId', isEqualTo: user.uid)
          .where('providerSeen', isEqualTo: false)
          .snapshots(),
      builder: (context, gelenSnapshot) {
        final bool gelenIstekBildirimiVar =
            temizSnapshotMu(gelenSnapshot);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('booking_requests')
              .where('customerId', isEqualTo: user.uid)
              .where('customerSeen', isEqualTo: false)
              .snapshots(),
          builder: (context, gonderilenSnapshot) {
            final bool gonderilenIstekBildirimiVar =
                temizSnapshotMu(gonderilenSnapshot);

            final bool istekBildirimiVar =
                gelenIstekBildirimiVar || gonderilenIstekBildirimiVar;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where(
                'unreadFor',
                arrayContains: user.uid,
              )
              .snapshots(includeMetadataChanges: true),
          builder: (context, messageSnapshot) {
            final bool mesajBildirimiVar = temizSnapshotMu(messageSnapshot);

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
  );
 }
}