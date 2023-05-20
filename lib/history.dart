import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<List<Map<String, dynamic>>> getDocumentsByRollNo(String rollNo) async {
  final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('print').get();

  final List<Map<String, dynamic>> documents =
      snapshot.docs.where((doc) => doc.data()['id'] == rollNo).map((doc) {
    final Map<String, dynamic> data = doc.data();
    data['batchId'] = doc.id;
    return data;
  }).toList();

  return documents;
}

class DocumentList extends StatelessWidget {
  final String rollNo;

  const DocumentList({required this.rollNo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getDocumentsByRollNo(rollNo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Scaffold(
              body: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final document = snapshot.data![index];
                  final urlArr = document['urlArr'] as List<dynamic>;
                  return ListTile(
                    title: Text(document['id']),
                    subtitle: Text(
                        'Total Pages : ${document['pages']} | Total Amount : ${document['Amount']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Transaction Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Batch Id - ${document['batchId']}'),
                                const SizedBox(
                                  height: 20,
                                ),
                                for (var doc in urlArr)
                                  Text(
                                    '${doc['name']} \n Received by You : ${document['isGiven'] ? 'Yes' : 'No'} \n Is It Printed : ${document['isPrinted'] ? 'Yes' : 'No'} \n',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text('No documents found for rollNo $rollNo'),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
