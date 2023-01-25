import 'dart:async';

class TotalCountStream{

  final _countStremContr = StreamController<int>.broadcast();

  Stream<int> get count => _countStremContr.stream;



  void addTotalCount(totalCount){

    _countStremContr.sink.add(totalCount);
    print(">>>>>><<<<<<$totalCount");
  }

  void dispose(){
    _countStremContr.close();
  }
}

var coutStream= TotalCountStream();
