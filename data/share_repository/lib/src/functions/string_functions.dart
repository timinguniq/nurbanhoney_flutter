class StringFunctions{
  String formattingToCreatedAt(String input){
    try{
      final inputArray = input.split('T')[0].split('-');
      final result = '${inputArray[0]}.${inputArray[1]}.${inputArray[2]}';
      return result;
    }catch(e){
      print('formattingToCreatedAt error : $e');
      return '';
    }
  }

  // 휘장을 String을 받아서 List<String>으로 변환
  List<String> convertToInsignia(String insignia){
    var result = <String>[];
    try{
      final tempInsignia = insignia.replaceAll('[', '').replaceAll(']', '').trim();
      result = tempInsignia.split(',').toList();
    }catch(e){
      print('convertToInsignia error : $e');
    }
    return result;
  }
}
