import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../streams/total_count_stream.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String counterKey = 'home_counter';
  ScrollController listScrollController = ScrollController();

  Future<List<String>> _getHistoryListFromHive() async {
    final box = Hive.box<dynamic>('mybox');
    List<String> list = box.get(counterKey) ?? [];
    print("list >> $list");
    return list;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3D345F),
        title: const Text('History'),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor:Color(0xff3D345F),
      //   onPressed: () {
      //     if (listScrollController.hasClients) {
      //       final position = listScrollController.position.maxScrollExtent;
      //       listScrollController.animateTo(
      //         position,
      //         duration: Duration(seconds: 3),
      //         curve: Curves.easeOut,
      //       );
      //     }
      //   },
      //   isExtended: true,
      //   tooltip: "Scroll to top",
      //   child: Icon(Icons.arrow_upward),
      // ),
      body: FutureBuilder(
          future: _getHistoryListFromHive(),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            var sum = 0;
            var arr = [];
            if (snapshot.hasData) {
              return ListView.builder(
                  controller: listScrollController,
                  physics: BouncingScrollPhysics(),
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var total = int.parse(snapshot.data![index].split(" ")[0]);
                    arr.add(total);
                    var totalCount;
                    print(arr[arr.length-1]);
                    if (snapshot.data!.length == arr.length) {
                      totalCount =
                          arr.reduce((value, element) => value + element);
                      coutStream.addTotalCount(totalCount);
                    }


                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 27.0),
                      // isThreeLine: true,
                      leading: Column(
                        children: [
                          Text(
                              snapshot.data![index].split(" ")[1].split("-")[0],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: size.width / 18)),
                          Text(
                              _getMonth(int.tryParse(snapshot.data![index]
                                  .split(" ")[1]
                                  .split("-")[1])!),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: size.width / 40)),
                          Text(
                              snapshot.data![index].split(" ")[1].split("-")[2],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: size.width / 36)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(snapshot.data![index].split(" ")[2],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 17)),
                          SizedBox(width: 6),
                          Text(snapshot.data![index].split(" ")[3],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 17)),
                        ],
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(' Beads ${snapshot.data![index].split(" ")[0]}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  });
            } else if (snapshot.hasError) {
              return Container(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const CircularProgressIndicator(color: Colors.black);
            }
          }),
    );
  }

  String _getMonth(int monthInNum) {
    switch (monthInNum) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }
}
