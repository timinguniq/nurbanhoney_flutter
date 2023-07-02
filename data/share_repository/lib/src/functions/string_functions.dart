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
}
